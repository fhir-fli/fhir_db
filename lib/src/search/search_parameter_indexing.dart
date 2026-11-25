import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:fhir_db/src/created_on_first_use.dart';
import 'package:fhir_db/src/search/custom_search_parameters.dart';

/// Where one uploaded search parameter code stands in the store's
/// re-indexing ([SearchParameterIndexing.status]).
enum SearchParameterIndexState {
  /// Queued and not running: its turn has not come, or the run that had it
  /// stopped (its process ended) and the next one picks it up.
  waiting,

  /// Being re-indexed now, by a connection that showed it was alive within
  /// [SearchParameterIndexing.staleAfter].
  running,

  /// The last run ended and read the stored resources; nothing is queued.
  done,

  /// The last run ended with an error; nothing is queued.
  failed,
}

/// One code's row in the store's re-indexing record.
class SearchParameterIndexStatus {
  /// Creates the record.
  const SearchParameterIndexStatus({
    required this.code,
    required this.state,
    required this.queued,
    this.interrupted = false,
    this.runningSince,
    this.started,
    this.finished,
    this.resourcesRead,
    this.error,
  });

  /// The `SearchParameter.code`.
  final String code;

  /// Where it stands.
  final SearchParameterIndexState state;

  /// When it was last queued.
  final DateTime queued;

  /// Whether a run took it and stopped before it ended: the process that
  /// held it ended or went unheard for [SearchParameterIndexing.staleAfter].
  /// It is [SearchParameterIndexState.waiting], and runs again.
  final bool interrupted;

  /// When the run now under way began, when [state] is running or it was
  /// [interrupted].
  final DateTime? runningSince;

  /// When the last run that ended began; null before one has ended.
  final DateTime? started;

  /// When it ended.
  final DateTime? finished;

  /// Resources it read; null when it failed or none has ended.
  final int? resourcesRead;

  /// Why it failed; null when it succeeded or none has ended.
  final String? error;
}

/// A run stopped before its next write: the connection is closing, or the
/// run went unheard for longer than [SearchParameterIndexing.staleAfter]
/// and another connection took the store's re-indexing over.
class SearchParameterIndexingStopped implements Exception {
  /// Creates the signal; [reason] says which.
  const SearchParameterIndexingStopped(this.reason);

  /// Why the run stopped.
  final String reason;

  @override
  String toString() => 'Search parameter re-index stopped: $reason';
}

/// The re-indexing a store does by itself when its uploaded search
/// parameters change (`FhirDb.reindexOnSearchParameterChange`), kept in the
/// store file so every connection to it sees one record.
///
/// Two tables, created on first use. `search_parameter_indexing` has one
/// row per code ever queued: how many times it was queued (`wanted`), how
/// many of those the last finished run covered (`done`), the run under way
/// and the last one that ended. `search_parameter_indexer` holds at most
/// one row, the lease: which connection runs the queue, and when it last
/// showed it was alive.
///
/// Why in the store: an app's background service and its screens each
/// open their own connection to the file, and each kept this record in
/// memory, so a screen could not see indexing the service started; and a
/// run whose process Android ended was lost, with nothing to start it
/// again. Now any connection reads [status], and a lease not renewed
/// within [staleAfter] is taken over by the next connection that queues a
/// code, first uses the store, or retries after [staleAfter], as fhirant's
/// `$sync` lease is (30 s renewals, 2 min to go stale).
///
/// One code at a time across the store, in the order they were queued. A
/// code queued again while its run is under way runs again after it: its
/// definition changed after that run read the registry.
class SearchParameterIndexing {
  /// The record of [_db], whose runs call [_reindex] while [_enabled]
  /// answers true.
  SearchParameterIndexing(this._db, this._reindex, this._enabled);

  final DatabaseConnectionUser _db;

  /// Re-indexes one code, calling its argument before each write it makes;
  /// that throws [SearchParameterIndexingStopped] when the run must stop.
  final Future<int> Function(String code, Future<void> Function() stillHeld)
      _reindex;

  final bool Function() _enabled;

  /// How often a run renews the lease.
  Duration heartbeat = const Duration(seconds: 30);

  /// How long the lease stands without renewal before another connection
  /// takes it over.
  Duration staleAfter = const Duration(minutes: 2);

  /// The queue's table.
  static const queueTable = 'search_parameter_indexing';

  /// The lease's table.
  static const leaseTable = 'search_parameter_indexer';

  static final Random _random = Random.secure();

  late final _tables = CreatedOnFirstUse(_create);

  Future<void> _create() async {
    await _db.customStatement(
      'CREATE TABLE IF NOT EXISTS $queueTable ( '
      'code TEXT NOT NULL PRIMARY KEY, '
      'wanted INTEGER NOT NULL, '
      'done INTEGER NOT NULL, '
      'queued INTEGER NOT NULL, '
      'holder TEXT, '
      'running_since INTEGER, '
      'run_wanted INTEGER, '
      'started INTEGER, '
      'finished INTEGER, '
      'resources_read INTEGER, '
      'error TEXT)',
    );
    await _db.customStatement(
      'CREATE TABLE IF NOT EXISTS $leaseTable ( '
      'id INTEGER NOT NULL PRIMARY KEY CHECK (id = 0), '
      'holder TEXT NOT NULL, '
      'heartbeat INTEGER NOT NULL)',
    );
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  /// Queues [code] for re-indexing and starts this connection's run unless
  /// the lease is held. Called in the caller's zone: inside a transaction
  /// the row is that transaction's, gone if it rolls back; the run reads
  /// the queue after it commits.
  Future<void> schedule(String code) async {
    await _tables.use(
      () => _db.customStatement(
        'INSERT INTO $queueTable (code, wanted, done, queued) '
        'VALUES (?, 1, 0, ?) '
        'ON CONFLICT(code) DO UPDATE SET wanted = wanted + 1, '
        'queued = CASE WHEN wanted > done THEN queued ELSE excluded.queued END',
        [code, _now()],
      ),
    );
    resume();
  }

  /// Starts this connection's run if anything is queued and the lease is
  /// free or stale. The store calls it at first use.
  void resume() {
    if (_closed || !_enabled()) return;
    if (_running) {
      _again = true;
      return;
    }
    _running = true;
    _worker = _detached(_work);
  }

  bool _running = false;
  bool _again = false;
  bool _closed = false;
  Future<void>? _worker;
  Timer? _retry;

  /// The last error that ended this connection's run outside any one
  /// code's re-index (the store closed under it, a write refused); null
  /// when none has.
  Object? get workerError => _workerError;
  Object? _workerError;

  Future<void> _work() async {
    try {
      while (true) {
        _again = false;
        if (await _nextPending() == null) return;
        final holder = _newHolder();
        if (!await _claim(holder)) {
          // Another connection runs the queue, or held it and has not been
          // heard from within [staleAfter]: look again then.
          _retry?.cancel();
          _retry = Timer(staleAfter, resume);
          return;
        }
        await _drain(holder);
        if (_closed) return;
        // A connection that queued while this one held the lease found it
        // held, and left its code to this run.
        if (await _nextPending() == null && !_again) return;
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _drain(String holder) async {
    final renew = _renewEvery(holder);
    try {
      while (!_closed) {
        final code = await _nextPending();
        if (code == null) return;
        final took = await _db.customUpdate(
          'UPDATE $queueTable SET holder = ?, running_since = ?, '
          'run_wanted = wanted WHERE code = ? AND EXISTS '
          '(SELECT 1 FROM $leaseTable WHERE id = 0 AND holder = ?)',
          variables: [
            Variable.withString(holder),
            Variable.withInt(_now()),
            Variable.withString(code),
            Variable.withString(holder),
          ],
          updateKind: UpdateKind.update,
        );
        if (took == 0) return;
        final started = _now();
        int? read;
        String? error;
        try {
          read = await _reindex(code, () => _stillHeld(holder));
        } on SearchParameterIndexingStopped {
          // Left as it stands: queued, and taken up by the next run.
          return;
        } on Object catch (e) {
          if (_closed) return;
          error = '$e';
        }
        await _db.customUpdate(
          'UPDATE $queueTable SET done = run_wanted, holder = NULL, '
          'running_since = NULL, run_wanted = NULL, started = ?, '
          'finished = ?, resources_read = ?, error = ? '
          'WHERE code = ? AND holder = ? AND EXISTS '
          '(SELECT 1 FROM $leaseTable WHERE id = 0 AND holder = ?)',
          variables: [
            Variable.withInt(started),
            Variable.withInt(_now()),
            Variable<int>(read),
            Variable<String>(error),
            Variable.withString(code),
            Variable.withString(holder),
            Variable.withString(holder),
          ],
          updateKind: UpdateKind.update,
        );
      }
    } finally {
      renew.cancel();
      await _release(holder);
    }
  }

  /// Runs [body] holding the store's re-indexing lease, so no background
  /// run, in this connection or another, builds at the same time; waits
  /// while one holds it. [body] calls its argument before each write.
  /// Two builds of one code at once each delete the other's half-built
  /// rows: measured 2026-11-25, `reindexSearchParameter` called while the
  /// background run of the same code built lost a record saved meanwhile,
  /// three runs in three (fhir_r4_db `reindex_search_parameter_test.dart`).
  ///
  /// Not inside a transaction of the caller's: a background run waits for
  /// it to commit, and this for the run.
  Future<T> exclusive<T>(
    Future<T> Function(Future<void> Function() stillHeld) body,
  ) async {
    final holder = _newHolder();
    while (!await _tables.use(() => _claim(holder))) {
      if (_closed) {
        throw const SearchParameterIndexingStopped('the store is closing');
      }
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    final renew = _renewEvery(holder);
    try {
      return await body(() => _stillHeld(holder));
    } finally {
      renew.cancel();
      await _release(holder);
      // Codes queued while this held the lease were left to its holder.
      resume();
    }
  }

  static String _newHolder() => List.generate(
        16,
        (_) => _random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();

  Timer _renewEvery(String holder) => Timer.periodic(heartbeat, (_) {
        // A renewal that fails leaves the lease to go stale; the run finds
        // that out at its next write.
        unawaited(_renew(holder).then((_) {}, onError: (Object _) {}));
      });

  Future<void> _release(String holder) async {
    try {
      await _db.customStatement(
        'DELETE FROM $leaseTable WHERE id = 0 AND holder = ?',
        [holder],
      );
    } on Object catch (e) {
      // Left to go stale; the next run takes it over.
      _workerError = e;
    }
  }

  Future<String?> _nextPending() => _tables.use(() async {
        final row = await _db
            .customSelect(
              'SELECT code FROM $queueTable WHERE wanted > done '
              'ORDER BY queued, code LIMIT 1',
            )
            .getSingleOrNull();
        return row?.read<String>('code');
      });

  Future<bool> _claim(String holder) async {
    final now = _now();
    final n = await _db.customUpdate(
      'INSERT INTO $leaseTable (id, holder, heartbeat) VALUES (0, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET holder = excluded.holder, '
      'heartbeat = excluded.heartbeat '
      'WHERE $leaseTable.heartbeat < ?',
      variables: [
        Variable.withString(holder),
        Variable.withInt(now),
        Variable.withInt(now - staleAfter.inMilliseconds),
      ],
      updateKind: UpdateKind.update,
    );
    return n > 0;
  }

  Future<bool> _renew(String holder) async {
    final n = await _db.customUpdate(
      'UPDATE $leaseTable SET heartbeat = ? WHERE id = 0 AND holder = ?',
      variables: [Variable.withInt(_now()), Variable.withString(holder)],
      updateKind: UpdateKind.update,
    );
    return n > 0;
  }

  /// Renews [holder]'s lease, or throws [SearchParameterIndexingStopped]
  /// when the connection is closing or another took the lease over. A
  /// write, so called first in a transaction it takes the store's write
  /// lock before anything is read.
  Future<void> _stillHeld(String holder) async {
    if (_closed) {
      throw const SearchParameterIndexingStopped('the store is closing');
    }
    if (!await _renew(holder)) {
      throw const SearchParameterIndexingStopped(
        'another connection took the re-indexing over',
      );
    }
  }

  Future<bool> _leaseLive() async {
    final row = await _db
        .customSelect(
          'SELECT heartbeat FROM $leaseTable WHERE id = 0',
        )
        .getSingleOrNull();
    return row != null &&
        row.read<int>('heartbeat') >= _now() - staleAfter.inMilliseconds;
  }

  /// Completes when the store has nothing queued, or has codes queued that
  /// no connection is running and this one will not (its
  /// `reindexOnSearchParameterChange` is off, or it is closing). Waits for
  /// another connection's run too.
  Future<void> get idle async {
    while (true) {
      if (_running) await _worker;
      if (await _nextPending() == null) return;
      if (await _tables.use(_leaseLive)) {
        // Another connection's run, or this one's about to start.
        await Future<void>.delayed(const Duration(milliseconds: 20));
        continue;
      }
      if (_closed || !_enabled()) return;
      final before = _workerError;
      resume();
      await _worker;
      // A run that ended on an error of its own would end the same way
      // again.
      if (!identical(_workerError, before)) return;
    }
  }

  /// Every code ever queued in this store, by code.
  Future<List<SearchParameterIndexStatus>> status() => _tables.use(() async {
        final now = _now();
        final lease = await _db
            .customSelect(
              'SELECT holder, heartbeat FROM $leaseTable WHERE id = 0',
            )
            .getSingleOrNull();
        final liveHolder = lease != null &&
                lease.read<int>('heartbeat') >= now - staleAfter.inMilliseconds
            ? lease.read<String>('holder')
            : null;
        final rows = await _db
            .customSelect(
              'SELECT * FROM $queueTable ORDER BY code',
            )
            .get();
        DateTime? at(int? ms) =>
            ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
        return [
          for (final r in rows)
            () {
              final holder = r.read<String?>('holder');
              final runningSince = r.read<int?>('running_since');
              final running = holder != null && holder == liveHolder;
              final pending = r.read<int>('wanted') > r.read<int>('done');
              final error = r.read<String?>('error');
              return SearchParameterIndexStatus(
                code: r.read<String>('code'),
                state: running
                    ? SearchParameterIndexState.running
                    : pending
                        ? SearchParameterIndexState.waiting
                        : error != null
                            ? SearchParameterIndexState.failed
                            : SearchParameterIndexState.done,
                queued: at(r.read<int>('queued'))!,
                interrupted: runningSince != null && !running,
                runningSince: at(runningSince),
                started: at(r.read<int?>('started')),
                finished: at(r.read<int?>('finished')),
                resourcesRead: r.read<int?>('resources_read'),
                error: error,
              );
            }(),
        ];
      });

  /// Stops this connection's run before its next write and gives up the
  /// lease, so the next connection takes the queue up at once; the store
  /// calls it as it closes.
  Future<void> stop() async {
    _closed = true;
    _retry?.cancel();
    final worker = _worker;
    if (worker != null) await worker;
  }

  /// Runs [job] in a zone of its own under the root zone. Not in the
  /// caller's: a schedule inside a transaction would hand the run that
  /// transaction, closed by the time the run reads; under the root zone
  /// it waits for the commit. Guarded: an error nothing awaited would
  /// otherwise reach the root zone and end the process (measured
  /// 2026-11-23, fhir_db 0.15.7). Completes when [job] ends, either way.
  Future<void> _detached(Future<void> Function() job) {
    final done = Completer<void>();
    Zone.root.run(() {
      unawaited(
        runZonedGuarded(
          () async {
            try {
              await job();
            } on Object catch (e) {
              _workerError = e;
            } finally {
              if (!done.isCompleted) done.complete();
            }
          },
          (error, stack) => _workerError = error,
        ),
      );
    });
    return done.future;
  }
}

/// The codes whose uploaded definitions differ between [before] and
/// [after]: added, removed, or changed in type, base, target or
/// expression. A code with no definition in either is not listed.
Set<String> changedSearchParameterCodes(
  CustomSearchParameters before,
  CustomSearchParameters after,
) {
  Map<String, Set<String>> byCode(CustomSearchParameters r) {
    final out = <String, Set<String>>{};
    for (final p in r.all) {
      out.putIfAbsent(p.code, () => {}).add(
            [
              p.type,
              (p.bases.toList()..sort()).join(','),
              (p.targets.toList()..sort()).join(','),
              p.expression,
            ].join('\u0000'),
          );
    }
    return out;
  }

  final a = byCode(before);
  final b = byCode(after);
  bool same(Set<String>? x, Set<String>? y) =>
      x != null && y != null && x.length == y.length && x.containsAll(y);
  return {
    for (final code in {...a.keys, ...b.keys})
      if (!same(a[code], b[code])) code,
  };
}
