import 'dart:io';

import 'package:drift/native.dart';
import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// A store's version stamps (`meta.lastUpdated`) only go forward, even when
/// the machine's clock is set back: a history read with `_since` (R4B
/// http.html §3.1.0.12) would otherwise never return a version stamped
/// before one already read. A clock set back is simulated by a last stamp
/// ahead of now, which is the state it leaves.
void main() {
  late FhirDb<JsonNode, String> db;
  late FhirDao<JsonNode, String> dao;

  setUp(() {
    db = FhirDb(NativeDatabase.memory(), model: JsonModel());
    dao = db.fhirDao;
  });
  tearDown(() => db.close());

  JsonNode patient(String id, [String gender = 'female']) => JsonNode.resource(
        {
          'resourceType': 'Patient',
          'id': id,
          'gender': gender,
        },
      );

  final ahead = DateTime.utc(2099);

  Future<void> setLastStamp(DateTime at) => db.customStatement(
        'UPDATE store_clock SET last_stamp = ${at.microsecondsSinceEpoch}',
      );

  test('with a clock that is right, a version is stamped now', () async {
    final before = DateTime.now().toUtc();
    final saved = await dao.saveResource(patient('a'));
    final after = DateTime.now().toUtc();
    expect(saved.metaLastUpdated!.isBefore(before), isFalse);
    expect(saved.metaLastUpdated!.isAfter(after), isFalse);
  });

  test('after the clock is set back, a save is stamped after the last one',
      () async {
    await dao.saveResource(patient('a'));
    await setLastStamp(ahead);

    final update = await dao.saveResource(patient('a', 'male'));
    final created = await dao.saveResource(patient('b'));

    expect(update.metaLastUpdated!.isAfter(ahead), isTrue);
    expect(created.metaLastUpdated!.isAfter(update.metaLastUpdated!), isTrue);
    // And `_lastUpdated` (as `_since` does) finds both after the last stamp.
    final found = await dao.search(
      resourceType: 'Patient',
      searchParameters: {
        '_lastUpdated': ['ge2099-01-01'],
      },
    );
    expect(found.map((r) => r.resourceId), unorderedEquals(['a', 'b']));
  });

  test('a delete after the clock is set back is stamped after the last one',
      () async {
    await dao.saveResource(patient('a'));
    await setLastStamp(ahead);

    expect(await dao.deleteResource('Patient', 'a'), isTrue);

    final history = await dao.getHistory('Patient', 'a');
    final tombstone = history.firstWhere((e) => e.deleted);
    // The history column holds milliseconds, so the microsecond after the
    // last stamp reads as the same instant: not before it is what `_since`
    // ("at or after") needs.
    expect(tombstone.lastUpdated.isBefore(ahead), isFalse);
  });

  test('a batch saved after the clock is set back keeps going forward',
      () async {
    await dao.saveResource(patient('a'));
    await setLastStamp(ahead);

    final saved = await dao.saveResourceList([
      patient('x'),
      patient('y'),
      patient('x', 'male'),
    ]);

    final stamps = saved.map((r) => r.metaLastUpdated!).toList();
    expect(stamps.first.isAfter(ahead), isTrue);
    for (var i = 1; i < stamps.length; i++) {
      expect(stamps[i].isAfter(stamps[i - 1]), isTrue, reason: '$stamps');
    }
  });

  test(
      'a store opened before the clock table existed starts at its latest '
      'stored time', () async {
    final dir = await Directory.systemTemp.createTemp('fhir_db_stamp_');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/store.sqlite');

    final first = FhirDb(NativeDatabase(file), model: JsonModel());
    await first.fhirDao.saveResource(patient('a'));
    // As a store written by a release without the clock: no table, and the
    // latest stored version stamped by a clock that has since gone back.
    await first.customStatement('DROP TABLE store_clock');
    await first.customStatement(
      'UPDATE resources SET last_updated = ${ahead.millisecondsSinceEpoch}',
    );
    await first.close();

    final second = FhirDb(NativeDatabase(file), model: JsonModel());
    final saved = await second.fhirDao.saveResource(patient('b'));
    expect(saved.metaLastUpdated!.isAfter(ahead), isTrue);
    await second.close();
  });

  test('_since keeps a version saved at the instant it names', () async {
    // R4B http.html §3.1.0.12: "created at or after the given instant".
    final saved = await dao.saveResource(patient('a'));
    final history =
        await dao.getHistory('Patient', 'a', since: saved.metaLastUpdated);
    expect(history, hasLength(1));
  });

  test('a preserved meta keeps its own time and takes no stamp', () async {
    final kept = await dao.saveResource(
      JsonNode.resource({
        'resourceType': 'Patient',
        'id': 'fetched',
        'meta': {'versionId': '7', 'lastUpdated': '2026-09-08T10:01:21Z'},
      }),
      preserveMeta: true,
    );
    expect(kept.metaLastUpdated, DateTime.utc(2026, 9, 8, 10, 1, 21));
  });
}
