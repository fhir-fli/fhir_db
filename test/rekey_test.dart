import 'dart:io';

import 'package:drift/native.dart';
import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// Changing the store's key: the rows stay, the new key opens the file,
/// the old key no longer does. A file store under SQLCipher 4 through
/// sqlite3mc, the way the apps open it (`cipherSetup`).
void main() {
  const key1 =
      '0f1e2d3c4b5a69788796a5b4c3d2e1f00f1e2d3c4b5a69788796a5b4c3d2e1f0';
  const key2 =
      'ffeeddccbbaa99887766554433221100ffeeddccbbaa99887766554433221100';
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('fhir_db_rekey_');
    file = File('${dir.path}/store.db');
  });
  tearDown(() => dir.delete(recursive: true));

  FhirDb<JsonNode, String> open(String key) =>
      FhirDb(NativeDatabase(file, setup: cipherSetup(key)), model: JsonModel());

  test('the instrument: a wrong key cannot open the store', () async {
    final db = open(key1);
    await db.customStatement('CREATE TABLE t (x INTEGER)');
    await db.close();
    final wrong = open(key2);
    await expectLater(
      wrong.customSelect('SELECT count(*) FROM sqlite_master').get(),
      throwsA(anything),
      reason: 'the build has no cipher: the test cannot measure rekey',
    );
    await wrong.close();
  });

  test('rekey keeps the rows, moves the file to the new key', () async {
    final db = open(key1);
    await db.fhirDao.saveResource(
      jsonResource({'resourceType': 'Patient', 'id': 'p1'}),
    );
    await db.rekey(key2);
    await db.close();

    final old = open(key1);
    await expectLater(
      old.customSelect('SELECT count(*) FROM sqlite_master').get(),
      throwsA(anything),
      reason: 'the old key still opens the store',
    );
    await old.close();

    final renewed = open(key2);
    final rows =
        await renewed.customSelect('SELECT count(*) AS n FROM resources').get();
    expect(rows.single.read<int>('n'), 1);
    final patient = await renewed.fhirDao.getResource('Patient', 'p1');
    expect(patient?.resourceId, 'p1');
    await renewed.close();
  });

  test('an empty or short key is refused, the store is untouched', () async {
    final db = open(key1);
    await expectLater(() => db.rekey(''), throwsArgumentError);
    await expectLater(() => db.rekey('abc'), throwsArgumentError);
    await expectLater(
      () => db.rekey("x'; DROP TABLE t; --"),
      throwsArgumentError,
    );
    await db.close();
    final same = open(key1);
    expect(
      (await same.customSelect('SELECT count(*) FROM sqlite_master').get())
          .length,
      1,
    );
    await same.close();
  });

  test('rekeyWithPassword derives the key from the password and the salt',
      () async {
    final key = (await deriveDbKey(password: 'first', dbPath: dir.path))!;
    final db = open(key);
    await db.fhirDao.saveResource(
      jsonResource({'resourceType': 'Patient', 'id': 'p2'}),
    );
    await db.rekeyWithPassword(newPassword: 'second', dbPath: dir.path);
    await db.close();
    final key2 = (await deriveDbKey(password: 'second', dbPath: dir.path))!;
    expect(key2, isNot(key));
    final renewed = open(key2);
    expect(
      (await renewed.fhirDao.getResource('Patient', 'p2'))?.resourceId,
      'p2',
    );
    await renewed.close();
  });
}
