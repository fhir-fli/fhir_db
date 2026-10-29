import 'package:drift/native.dart';
import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// `FhirDao.saveResourceList`: the list save that hands back what it
/// stored, so a caller holding many writes (fhirant's transaction Bundle)
/// can make them in one call instead of one `saveResource` each. What it
/// stores must be what `saveResource` would have stored, row for row.
void main() {
  late FhirDb<JsonNode, String> db;
  late FhirDao<JsonNode, String> dao;

  setUp(() {
    db = FhirDb(NativeDatabase.memory(), model: JsonModel());
    dao = db.fhirDao;
  });
  tearDown(() => db.close());

  JsonNode observation(String id, {String? lastUpdated}) => jsonResource({
        'resourceType': 'Observation',
        'id': id,
        if (lastUpdated != null)
          'meta': {'versionId': '1', 'lastUpdated': lastUpdated},
        'status': 'final',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': '8480-6'},
          ],
        },
        'subject': {'reference': 'Patient/p1'},
        'effectiveDateTime': '2024-03-01T10:00:00Z',
        'valueQuantity': {
          'value': 120,
          'code': 'mm[Hg]',
          'system': 'http://unitsofmeasure.org',
        },
      });

  const indexTables = [
    'string_search_parameters',
    'token_search_parameters',
    'reference_search_parameters',
    'date_search_parameters',
    'number_search_parameters',
    'quantity_search_parameters',
    'uri_search_parameters',
    'composite_search_parameters',
    'special_search_parameters',
  ];

  Future<List<String>> indexRows(FhirDb<JsonNode, String> of) async => [
        for (final table in indexTables)
          for (final row in await of.customSelect('SELECT * FROM $table').get())
            '$table ${row.data}',
      ]..sort();

  test('returns each resource as stored, in the order given', () async {
    final saved =
        await dao.saveResourceList([observation('b'), observation('a')]);
    expect([for (final r in saved) r.resourceId], ['b', 'a']);
    for (final r in saved) {
      final stored = await dao.getResource('Observation', r.resourceId!);
      expect(stored!.json, r.json);
      expect((r.json['meta'] as Map)['versionId'], '1');
      expect((r.json['meta'] as Map)['lastUpdated'], isNotNull);
    }
  });

  test('stores the rows and index rows saveResource stores', () async {
    // The same resources, one store through saveResource and one through
    // saveResourceList; meta kept as given, so lastUpdated is the same.
    final other = FhirDb(NativeDatabase.memory(), model: JsonModel());
    addTearDown(other.close);
    final given = [
      for (var i = 0; i < 5; i++)
        observation('o$i', lastUpdated: '2026-10-28T12:00:0${i}Z'),
    ];
    for (final r in given) {
      await other.fhirDao.saveResource(r, preserveMeta: true);
    }
    await dao.saveResourceList(given, preserveMeta: true);
    final one = await indexRows(other);
    expect(one, isNotEmpty);
    expect(await indexRows(db), one);
    final rows = await db.customSelect('SELECT * FROM resources').get();
    final otherRows = await other.customSelect('SELECT * FROM resources').get();
    expect(
      [for (final r in rows) r.data.toString()]..sort(),
      [for (final r in otherRows) r.data.toString()]..sort(),
    );
  });

  test('a stored resource gets the next version, the old one in history',
      () async {
    await dao.saveResource(observation('o1'));
    final saved = await dao.saveResourceList([observation('o1')]);
    expect((saved.single.json['meta'] as Map)['versionId'], '2');
    final history = await dao.getResourceHistory('Observation', 'o1');
    expect(
      [for (final h in history) (h.json['meta'] as Map)['versionId']]..sort(),
      ['1', '2'],
    );
  });

  test('a failure is thrown and stores nothing', () async {
    final extract = dao.extractSearchParameters;
    dao.extractSearchParameters = (r) => r.resourceId == 'bad'
        ? throw StateError('indexing failed')
        : extract(r);
    await expectLater(
      dao.saveResourceList([observation('good'), observation('bad')]),
      throwsStateError,
    );
    expect(await dao.getResource('Observation', 'good'), isNull);
    expect(await indexRows(db), isEmpty);
    // saveResources answers the same failure with false.
    expect(
      await dao.saveResources([observation('good'), observation('bad')]),
      isFalse,
    );
  });

  test('an empty list stores nothing and returns nothing', () async {
    expect(await dao.saveResourceList([]), isEmpty);
  });
}
