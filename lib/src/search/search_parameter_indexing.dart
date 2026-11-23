import 'dart:async';

import 'package:fhir_db/src/search/custom_search_parameters.dart';

/// How the last re-index of one uploaded search parameter code ended.
class SearchParameterIndexed {
  /// Creates the record.
  const SearchParameterIndexed({
    required this.code,
    required this.started,
    required this.finished,
    this.resourcesRead,
    this.error,
  });

  /// The `SearchParameter.code` re-indexed.
  final String code;

  /// When the re-index began.
  final DateTime started;

  /// When it ended.
  final DateTime finished;

  /// Resources read, null when it failed.
  final int? resourcesRead;

  /// Why it failed, null when it succeeded.
  final String? error;
}

/// The re-indexing a store starts by itself when its uploaded search
/// parameters change (`FhirDb.reindexOnSearchParameterChange`): which codes
/// are waiting or running, and how each one's last re-index ended. One
/// code at a time, in the order the changes were saved.
class SearchParameterIndexing {
  final List<String> _waiting = [];
  String? _running;
  final Map<String, SearchParameterIndexed> _last = {};
  Future<void> _queue = Future<void>.value();

  /// The code being re-indexed now, or null.
  String? get running => _running;

  /// The codes waiting their turn, in order.
  List<String> get waiting => List.unmodifiable(_waiting);

  /// How each code's last re-index ended, by code.
  Map<String, SearchParameterIndexed> get last => Map.unmodifiable(_last);

  /// Completes when nothing is waiting or running.
  Future<void> get idle async {
    while (_running != null || _waiting.isNotEmpty) {
      await _queue;
    }
  }

  /// Queues [code] for [reindex] unless it is already waiting. A code
  /// whose re-index is running is queued again: its definition changed
  /// after that run read the registry.
  void schedule(String code, Future<int> Function(String code) reindex) {
    if (_waiting.contains(code)) return;
    _waiting.add(code);
    _queue = _queue.then((_) async {
      _waiting.remove(code);
      _running = code;
      final started = DateTime.now();
      try {
        final read = await reindex(code);
        _last[code] = SearchParameterIndexed(
          code: code,
          started: started,
          finished: DateTime.now(),
          resourcesRead: read,
        );
      } on Object catch (e) {
        // Nobody awaits this job; its failure is reported here, where the
        // store's owner reads it.
        _last[code] = SearchParameterIndexed(
          code: code,
          started: started,
          finished: DateTime.now(),
          error: '$e',
        );
      } finally {
        _running = null;
      }
    });
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
