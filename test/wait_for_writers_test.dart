import 'dart:io';

import 'package:fhir_db/fhir_db.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// `waitForWriters`: a write that finds another connection's write lock
/// held waits for it by the clock, then fails with "database is locked".
void main() {
  late Directory dir;
  late Database holder;
  late Database waiter;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('fhir_db_wait_');
    final path = '${dir.path}/w.db';
    holder = sqlite3.open(path)
      ..execute('PRAGMA journal_mode = WAL')
      ..execute('CREATE TABLE t (x)');
    waiter = sqlite3.open(path);
  });

  tearDown(() {
    waiter.close();
    holder.close();
    dir.deleteSync(recursive: true);
  });

  test('waits its whole timeout for a write lock held throughout', () {
    waitForWriters(waiter, timeout: const Duration(seconds: 2));
    holder.execute('BEGIN IMMEDIATE');
    final clock = Stopwatch()..start();
    expect(
      () => waiter.execute('BEGIN IMMEDIATE'),
      throwsA(
        isA<SqliteException>().having((e) => e.resultCode, 'code', 5),
      ),
    );
    expect(clock.elapsedMilliseconds, inInclusiveRange(2000, 4000));
    holder.execute('ROLLBACK');
  });

  test('a second statement gets the whole timeout again', () {
    waitForWriters(waiter, timeout: const Duration(milliseconds: 500));
    holder.execute('BEGIN IMMEDIATE');
    for (var i = 0; i < 2; i++) {
      final clock = Stopwatch()..start();
      expect(
        () => waiter.execute('BEGIN IMMEDIATE'),
        throwsA(isA<SqliteException>()),
      );
      expect(clock.elapsedMilliseconds, greaterThanOrEqualTo(500));
    }
    holder.execute('ROLLBACK');
  });
}
