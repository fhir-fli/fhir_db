import 'package:drift/native.dart';
import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// A resource fetched from a server keeps that server's `meta` when the
/// caller asks (fhir-fli/fhir_r4 issue #39 and PR #40, xtMartinEberl,
/// 2026-09-17). Every save used to stamp `meta.lastUpdated = now` and count
/// `versionId` on, which is right for a resource the caller authored (R4B
/// http.html "update": the server populates versionId and lastUpdated) and
/// wrong for a cached copy of another server's resource: the cache then
/// showed the time of the last sync, not the time the server last changed
/// the resource, and "is the remote copy newer?" compared an edit time
/// against a local write time.
void main() {
  late FhirDb<JsonNode, String> db;
  late FhirDao<JsonNode, String> dao;

  setUp(() {
    db = FhirDb(NativeDatabase.memory(), model: JsonModel());
    dao = db.fhirDao;
  });
  tearDown(() => db.close());

  JsonNode fetched({String id = 'qr1', Map<String, dynamic>? meta}) =>
      JsonNode.resource({
        'resourceType': 'Patient',
        'id': id,
        if (meta != null) 'meta': meta,
        'name': [
          {'family': 'Fetched'},
        ],
      });

  const serverMeta = {
    'versionId': '7',
    'lastUpdated': '2026-09-08T10:01:21Z',
    'tag': [
      {'system': 'http://origin.example/tags', 'code': 'origin'},
    ],
  };

  test('preserveMeta stores the meta as received', () async {
    final saved =
        await dao.saveResource(fetched(meta: serverMeta), preserveMeta: true);
    expect(saved.json['meta'], serverMeta);
    final read = await dao.getResource('Patient', 'qr1');
    expect(read!.json['meta'], serverMeta);
    expect(read.metaVersionId, '7');
    expect(read.metaLastUpdated, DateTime.utc(2026, 9, 8, 10, 1, 21));
  });

  test('the preserved lastUpdated is what _lastUpdated searches and sorts by',
      () async {
    await dao.saveResource(fetched(meta: serverMeta), preserveMeta: true);
    await dao.saveResource(fetched(id: 'local'));
    Future<List<String>> ids(Map<String, List<String>> p) async =>
        (await dao.search(resourceType: 'Patient', searchParameters: p))
            .map((r) => r.resourceId!)
            .toList();
    expect(
      await ids({
        '_lastUpdated': ['lt2026-09-09'],
      }),
      ['qr1'],
    );
    expect(
      await ids({
        '_lastUpdated': ['ge2026-09-09'],
      }),
      ['local'],
    );
    final sorted = await dao.search(
      resourceType: 'Patient',
      sort: ['-_lastUpdated'],
    );
    expect(sorted.map((r) => r.resourceId), ['local', 'qr1']);
  });

  test('a later save without preserveMeta versions on from the kept one',
      () async {
    await dao.saveResource(fetched(meta: serverMeta), preserveMeta: true);
    final edited = await dao.saveResource(fetched(meta: serverMeta));
    expect(edited.metaVersionId, '8');
    expect(
      edited.metaLastUpdated!.isAfter(DateTime.utc(2026, 9, 9)),
      isTrue,
    );
    final history = await dao.getResourceHistory('Patient', 'qr1');
    expect(
      history.map((r) => r.metaVersionId).toSet(),
      containsAll(['7', '8']),
    );
  });

  test('preserveMeta without a lastUpdated is an ordinary versioned save',
      () async {
    // Nothing to preserve: a locally authored resource, or one whose
    // origin sent no meta, is stamped as before.
    final saved = await dao.saveResource(
      fetched(meta: const {'versionId': '7'}),
      preserveMeta: true,
    );
    expect(saved.metaVersionId, '1');
    expect(saved.metaLastUpdated, isNotNull);
    final bare = await dao.saveResource(fetched(id: 'p2'), preserveMeta: true);
    expect(bare.metaVersionId, '1');
  });

  test('saveResources takes the same flag', () async {
    final ok = await dao.saveResources(
      [fetched(meta: serverMeta), fetched(id: 'p2')],
      preserveMeta: true,
    );
    expect(ok, isTrue);
    expect((await dao.getResource('Patient', 'qr1'))!.json['meta'], serverMeta);
    expect((await dao.getResource('Patient', 'p2'))!.metaVersionId, '1');
  });
}
