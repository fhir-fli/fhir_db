import 'package:drift/native.dart';
import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// The store through the FhirModel seam alone: a JSON-backed FhirNode and
/// a hand-written extractor, no FHIR version linked. What a binding's
/// suite proves in depth (446 tests in fhir_r4_db) is proved here in
/// outline: the seam carries create, update, delete, history, search of
/// every parameter type, compartments and ValueSet expansion.
void main() {
  late FhirDb<JsonNode, String> db;
  late FhirDao<JsonNode, String> dao;

  setUp(() {
    db = FhirDb(NativeDatabase.memory(), model: JsonModel());
    dao = db.fhirDao;
  });
  tearDown(() => db.close());

  JsonNode patient(String id, {String family = 'Smith', String? gender}) =>
      JsonNode.resource({
        'resourceType': 'Patient',
        'id': id,
        'name': [
          {
            'family': family,
            'given': ['Ann'],
          },
        ],
        if (gender != null) 'gender': gender,
        'birthDate': '1980-05-02',
        'identifier': [
          {'system': 'urn:mrn', 'value': 'mrn-$id'},
        ],
      });

  JsonNode observation(String id, String patient, {double value = 120}) =>
      JsonNode.resource({
        'resourceType': 'Observation',
        'id': id,
        'status': 'final',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': '8480-6'},
          ],
        },
        'subject': {'reference': 'Patient/$patient'},
        'effectiveDateTime': '2024-03-01T10:00:00Z',
        'valueQuantity': {
          'value': value,
          'code': 'mm[Hg]',
          'system': 'http://unitsofmeasure.org',
        },
      });

  Future<List<String>> ids(
    String type,
    Map<String, List<String>> params,
  ) async =>
      (await dao.search(resourceType: type, searchParameters: params))
          .map((r) => r.resourceId!)
          .toList()
        ..sort();

  test('create stamps meta and assigns an id when there is none', () async {
    final saved = await dao.saveResource(
      JsonNode.resource({
        'resourceType': 'Patient',
        'name': [
          {'family': 'X'},
        ],
      }),
    );
    expect(saved.resourceId, isNotNull);
    expect(saved.metaVersionId, '1');
    expect(saved.metaLastUpdated, isNotNull);
    final read = await dao.getResource('Patient', saved.resourceId!);
    expect(read!.map['name'], [
      {'family': 'X'},
    ]);
  });

  test('update counts the version, merges tags, moves the old row to history',
      () async {
    await dao.saveResource(
      JsonNode.resource({
        ...patient('p1').map,
        'meta': {
          'tag': [
            {'system': 't', 'code': 'kept'},
          ],
        },
      }),
    );
    final v2 = await dao.saveResource(
      JsonNode.resource({
        ...patient('p1', family: 'Jones').map,
        'meta': {
          'tag': [
            {'system': 't', 'code': 'new'},
          ],
        },
      }),
    );
    expect(v2.metaVersionId, '2');
    expect(
      (v2.map['meta'] as Map)['tag'],
      [
        {'system': 't', 'code': 'kept'},
        {'system': 't', 'code': 'new'},
      ],
    );
    final history = await dao.getHistory('Patient', 'p1');
    expect(history.map((h) => h.versionId), ['2', '1']);
    expect(history.last.resource!.map['name'], [
      {
        'family': 'Smith',
        'given': ['Ann'],
      }
    ]);
    expect(await dao.countHistory('Patient', 'p1'), 2);
    final v1 = await dao.getVersion('Patient', 'p1', '1');
    expect(v1!.resource!.metaVersionId, '1');
  });

  test('ifMatchVersion guards an update and a delete', () async {
    await dao.saveResource(patient('p2'));
    expect(
      () => dao.saveResource(patient('p2'), ifMatchVersion: '9'),
      throwsA(isA<VersionConflict>()),
    );
    expect(
      () => dao.deleteResource('Patient', 'p2', ifMatchVersion: '9'),
      throwsA(isA<VersionConflict>()),
    );
    expect(
      await dao.deleteResource('Patient', 'p2', ifMatchVersion: '1'),
      isTrue,
    );
    final history = await dao.getHistory('Patient', 'p2');
    expect(history.first.deleted, isTrue);
    expect(history.map((h) => h.versionId), ['2', '1']);
    expect(await dao.getResource('Patient', 'p2'), isNull);
  });

  test(
      'search: token, string (words and :exact), date, reference, '
      'quantity, uri, _id, _lastUpdated', () async {
    await dao.saveResource(
      patient('a', family: 'Carreno Quinones', gender: 'female'),
    );
    await dao.saveResource(patient('b', family: 'Muñoz', gender: 'male'));
    await dao.saveResource(observation('o1', 'a'));
    await dao.saveResource(observation('o2', 'b', value: 80));
    await dao.saveResource(
      JsonNode.resource(
        {'resourceType': 'ValueSet', 'id': 'vs', 'url': 'http://x/vs'},
      ),
    );

    expect(
      await ids('Patient', {
        'gender': ['female'],
      }),
      ['a'],
    );
    expect(
      await ids('Patient', {
        'family': ['quinones'],
      }),
      ['a'],
    );
    expect(
      await ids('Patient', {
        'family': ['munoz'],
      }),
      ['b'],
    );
    expect(
      await ids('Patient', {
        'family:exact': ['Muñoz'],
      }),
      ['b'],
    );
    expect(
      await ids('Patient', {
        'family:exact': ['munoz'],
      }),
      isEmpty,
    );
    expect(
      await ids('Patient', {
        'name': ['ann'],
      }),
      ['a', 'b'],
    );
    expect(
      await ids('Patient', {
        'identifier': ['urn:mrn|mrn-a'],
      }),
      ['a'],
    );
    expect(
      await ids('Patient', {
        'birthdate': ['1980'],
      }),
      ['a', 'b'],
    );
    expect(
      await ids('Patient', {
        'birthdate': ['lt1980-05-02'],
      }),
      isEmpty,
    );
    expect(
      await ids('Patient', {
        '_id': ['b'],
      }),
      ['b'],
    );
    expect(
      await ids('Observation', {
        'subject': ['Patient/a'],
      }),
      ['o1'],
    );
    expect(
      await ids('Observation', {
        'patient': ['a'],
      }),
      ['o1'],
    );
    expect(
      await ids('Observation', {
        'code': ['http://loinc.org|8480-6'],
      }),
      ['o1', 'o2'],
    );
    expect(
      await ids('Observation', {
        'date': ['2024-03'],
      }),
      ['o1', 'o2'],
    );
    expect(
      await ids('Observation', {
        'value-quantity': ['gt100'],
      }),
      ['o1'],
    );
    expect(
      await ids('Observation', {
        'value-quantity': ['le80|http://unitsofmeasure.org|mm[Hg]'],
      }),
      ['o2'],
    );
    expect(
      await ids('ValueSet', {
        'url': ['http://x/vs'],
      }),
      ['vs'],
    );
    expect(
      await ids('Observation', {
        '_lastUpdated': ['gt2000'],
      }),
      ['o1', 'o2'],
    );
    expect(
      await dao.searchCount(
        resourceType: 'Patient',
        searchParameters: {
          'gender': ['male'],
        },
      ),
      1,
    );
  });

  test('chained and _has searches, and the compartment', () async {
    await dao.saveResource(patient('a', family: 'Alpha'));
    await dao.saveResource(patient('b', family: 'Beta'));
    await dao.saveResource(observation('o1', 'a'));
    await dao.saveResource(observation('o2', 'b'));
    expect(
      await ids('Observation', {
        'subject.family': ['alpha'],
      }),
      ['o1'],
    );
    expect(
      await ids('Observation', {
        'subject:Patient.family': ['beta'],
      }),
      ['o2'],
    );
    expect(
      (await dao.search(
        resourceType: 'Observation',
        compartment: const CompartmentScope('Patient', 'a'),
      ))
          .map((r) => r.resourceId),
      ['o1'],
    );
    final members =
        await dao.compartmentMembers(const CompartmentScope('Patient', 'a'));
    expect(members, {
      'Patient': {'a'},
      'Observation': {'o1'},
    });
    expect(
      await dao.compartmentTypeMembers('Patient', 'Observation'),
      {'o1', 'o2'},
    );
    expect(await dao.subjectOfCare('Observation', 'o2'), 'b');
  });

  test('a batch save, a bulk count, and the resource types held', () async {
    expect(
      await dao
          .saveResources([patient('a'), patient('b'), observation('o', 'a')]),
      isTrue,
    );
    expect(await dao.getResourceCount('Patient'), 2);
    expect(await dao.countResourcesOfType('Observation'), 1);
    expect(
      await dao.getResourceTypes(),
      unorderedEquals(['Patient', 'Observation']),
    );
    expect(await dao.exists('Patient', 'a'), isTrue);
  });

  test(':in expands a stored ValueSet by compose.include and exclude',
      () async {
    await dao.saveResource(
      JsonNode.resource({
        'resourceType': 'ValueSet',
        'id': 'vs',
        'url': 'http://x/vs',
        'compose': {
          'include': [
            {
              'system': 'http://loinc.org',
              'concept': [
                {'code': '8480-6'},
                {'code': '8462-4'},
              ],
            },
          ],
          'exclude': [
            {
              'system': 'http://loinc.org',
              'concept': [
                {'code': '8462-4'},
              ],
            },
          ],
        },
      }),
    );
    await dao.saveResource(patient('a'));
    await dao.saveResource(observation('o1', 'a'));
    expect(
      await ids('Observation', {
        'code:in': ['http://x/vs'],
      }),
      ['o1'],
    );
    expect(
      await ids('Observation', {
        'code:not-in': ['http://x/vs'],
      }),
      isEmpty,
    );
  });

  test('a contained resource is indexed under #Type and found by chain',
      () async {
    await dao.saveResource(
      JsonNode.resource({
        'resourceType': 'Observation',
        'id': 'oc',
        'status': 'final',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': '8480-6'},
          ],
        },
        'contained': [
          {
            'resourceType': 'Patient',
            'id': 'inner',
            'name': [
              {'family': 'Contained'},
            ],
          },
        ],
        'subject': {'reference': '#inner'},
      }),
    );
    final rows = await db
        .customSelect(
          'SELECT resource_type, id FROM string_search_parameters '
          "WHERE resource_type = '#Patient'",
        )
        .get();
    expect(rows, isNotEmpty);
    expect(
      rows.map((r) => r.read<String>('id')).toSet(),
      {'Observation/oc#inner'},
    );
    expect(
      await ids('Observation', {
        'subject.family': ['contained'],
      }),
      ['oc'],
    );
  });

  test('the schema is at version 14 and the index rebuild runs', () async {
    await dao.saveResource(patient('a'));
    await db.rebuildSearchIndex();
    expect(
      await ids('Patient', {
        'family': ['smith'],
      }),
      ['a'],
    );
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.read<int>('user_version'), 14);
  });
}
