import 'dart:io';

import 'package:sqlite3/sqlite3.dart';

/// Makes [db] wait up to [timeout] for another connection's write to
/// finish, timed by the clock, before a write of its own fails with
/// "database is locked". Call it in the connection's `setup`, in place of
/// `PRAGMA busy_timeout`; setting that pragma afterwards replaces this.
///
/// Only one connection to a file writes at a time; a second waits for the
/// first. `PRAGMA busy_timeout` waits by adding up the sleeps it asks for
/// (SQLite main.c `sqliteDefaultBusyCallback`, its `totals` table), and
/// each sleep is one `nanosleep` (os_unix.c `unixSleep`) that a signal ends
/// early. Dart's profiler sends one about every millisecond, and it runs
/// under `flutter test` (`--enable-dart-profiling`) and in debug and
/// profile builds (`flutter run` turns it on by default, flutter_tools
/// `commands/run.dart`). Measured 2026-11-25, SQLite 3.53.4, a 10 s
/// timeout against a held write lock: the pragma gave up after 115 ms with
/// the profiler on and 10,009 ms with it off; this waited 10,002 ms both
/// ways (fhir_r4_db `tool/probe_busy_timeout_wait.dart`).
///
/// SQLite asks again after each [poll] until the other write ends or
/// [timeout] has passed since it first found the lock held.
void waitForWriters(
  Database db, {
  Duration timeout = const Duration(seconds: 10),
  Duration poll = const Duration(milliseconds: 5),
}) {
  final waited = Stopwatch();
  db.busyHandler = (count) {
    // SQLite counts from 0 for each statement that finds the lock held.
    if (count == 0) {
      waited
        ..reset()
        ..start();
    }
    if (waited.elapsed >= timeout) return false;
    sleep(poll);
    return true;
  };
}
