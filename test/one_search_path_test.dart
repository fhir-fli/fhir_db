import 'package:drift/native.dart';
import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// Every search shape is answered by the one SQL path (fhirant
/// REVIEW-2026-09-17 ST4). Each case here used to make `_pagedIds` return
/// null and fall to the Dart set path, which read every matching id into
/// memory; `lastSearchPagedInSql` is the proof that it no longer does.
///
/// The sections cited are R4B search.html, read whole 2026-10-01.
void main() {
  late FhirDb<JsonNode, String> db;
  late FhirDao<JsonNode, String> dao;

  setUp(() async {
    db = FhirDb(NativeDatabase.memory(), model: JsonModel());
    dao = db.fhirDao;
    const families = [('p1', 'Alpha'), ('p2', 'Beta'), ('p3', 'Gamma')];
    for (final (id, family) in families) {
      await dao.saveResource(
        JsonNode.resource({
          'resourceType': 'Patient',
          'id': id,
          'name': [
            {'family': family},
          ],
          'gender': id == 'p2' ? 'male' : 'female',
        }),
      );
    }
    // o1 and o2 point at p1 and p2; o3 has no subject at all.
    for (final (id, subject) in [('o1', 'p1'), ('o2', 'p2'), ('o3', null)]) {
      await dao.saveResource(
        JsonNode.resource({
          'resourceType': 'Observation',
          'id': id,
          'status': 'final',
          'code': {
            'coding': [
              {'system': 'http://loinc.org', 'code': '8480-6'},
            ],
          },
          if (subject != null) 'subject': {'reference': 'Patient/$subject'},
        }),
      );
    }
  });
  tearDown(() => db.close());

  Future<List<String>> ids(
    String type,
    Map<String, List<String>> params, {
    List<HasParameter>? has,
    List<String>? sort,
    int? count,
  }) async =>
      (await dao.search(
        resourceType: type,
        searchParameters: params,
        hasParameters: has,
        sort: sort,
        count: count,
      ))
          .map((r) => r.resourceId!)
          .toList();

  test('_count=0 is an empty page, in SQL (3.1.1.5.3)', () async {
    // "if _count has the value 0 ... the server returns a bundle that
    // reports the total ... but with no entries". The set path paged with
    // `count > 0` as the only cut, so count 0 returned EVERY match.
    expect(await ids('Patient', {}, count: 0), isEmpty);
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('_id:missing and _lastUpdated:missing are answered in SQL', () async {
    // Every stored resource has both, so :missing=true is nothing and
    // :missing=false is everything.
    expect(
      await ids('Patient', {
        '_id:missing': ['true'],
      }),
      isEmpty,
    );
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await ids('Patient', {
        '_id:missing': ['false'],
      }),
      ['p1', 'p2', 'p3'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await ids('Patient', {
        '_lastUpdated:missing': ['true'],
      }),
      isEmpty,
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('_id takes no modifier but :missing', () async {
    // `_id` is a token by definition, but it is a column, not a coded
    // value: `:not`, `:text`, `:in` have no meaning on it. The set path
    // answered `_id:not=p1` with p1 itself.
    expect(
      () => ids('Patient', {
        '_id:not': ['p1'],
      }),
      throwsA(isA<UnsupportedSearchModifier>()),
    );
  });

  test('a chain on a parameter that is not a reference matches nothing',
      () async {
    // 3.1.1.4.15: "reference parameters may be chained". A token cannot
    // be followed, so nothing is reached through it.
    expect(
      await ids('Patient', {
        'gender.name': ['x'],
      }),
      isEmpty,
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('a chained parameter no target type defines is ignored', () async {
    // 3.1.1.3: "servers SHOULD ignore unknown or unsupported parameters".
    // The chain's last link names a parameter of the target, and one no
    // target has is unknown. The set path searched every target with it,
    // which (ignoring it there) matched every target, so the answer was
    // "has any subject" — o3, with no subject, was left out.
    expect(
      await ids('Observation', {
        'subject.nonsense': ['x'],
      }),
      ['o1', 'o2', 'o3'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('_has with an unknown search parameter keeps only the reference',
      () async {
    // The same rule inside `_has` (3.1.1.4.16): the unknown parameter is
    // ignored, and what remains is "referred to by at least one
    // Observation" through `subject`. p3 has none.
    expect(
      await ids(
        'Patient',
        {},
        has: [HasParameter.parse('_has:Observation:subject:nonsense', 'x')!],
      ),
      ['p1', 'p2'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('_has naming a type this store has no definition for is empty',
      () async {
    expect(
      await ids(
        'Patient',
        {},
        has: [HasParameter.parse('_has:Nonexistent:subject:code', 'x')!],
      ),
      isEmpty,
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('a _sort rule that names no orderable parameter is dropped', () async {
    // 3.1.1.5.1: "Each item in the comma separated list is a search
    // parameter". One that is not, or one whose type has no single value
    // to order by (a composite, a special), orders nothing; the rules
    // after it still apply.
    expect(await ids('Patient', {}, sort: ['nonsense']), ['p1', 'p2', 'p3']);
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await ids('Patient', {}, sort: ['nonsense', '-family']),
      ['p3', 'p2', 'p1'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await ids('Observation', {}, sort: ['code-value-quantity']),
      ['o1', 'o2', 'o3'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('a reference type modifier that names no resource type is refused',
      () async {
    // 3.1.1.4.4: a modifier the server does not support for the parameter
    // is a 400. `:Foo` is written like a type modifier (3.1.1.4.12) but
    // names nothing; the set path answered it as "no match".
    expect(
      () => ids('Observation', {
        'subject:Foo': ['p1'],
      }),
      throwsA(isA<UnsupportedSearchModifier>()),
    );
  });

  test('a type modifier with a typed value agrees or matches nothing',
      () async {
    // 3.1.1.4.12: `subject:Patient=23` "has the same effect as"
    // `subject=Patient/23`. A value that already carries the same type is
    // that search; one carrying another type contradicts the modifier,
    // and nothing can satisfy both (3.1.1.3, a logical condition).
    expect(
      await ids('Observation', {
        'subject:Patient': ['Patient/p1'],
      }),
      ['o1'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await ids('Observation', {
        'subject:Patient': ['Encounter/p1'],
      }),
      isEmpty,
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('_list and _content take no modifier; _text takes the string ones',
      () async {
    expect(
      () => ids('Patient', {
        '_list:exact': ['42'],
      }),
      throwsA(isA<UnsupportedSearchModifier>()),
    );
    expect(
      () => ids('Patient', {
        '_content:exact': ['x'],
      }),
      throwsA(isA<UnsupportedSearchModifier>()),
    );
    // This model indexes no narrative, so every resource lacks `_text`.
    expect(
      await ids('Patient', {
        '_text:missing': ['true'],
      }),
      ['p1', 'p2', 'p3'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await ids('Patient', {
        '_text:exact': ['anything'],
      }),
      isEmpty,
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('an _id list of any length is one bound JSON array, in SQL', () async {
    // The set path existed for this: 40,000 comma-separated ids (a
    // `_filter` result joined back as `_id`) built an OR chain that
    // overflowed the stack at 387 ms (measured 2026-09-08). In SQL the
    // list is one literal JSON array read by json_each.
    final many = [
      for (var i = 0; i < 40000; i++) 'absent$i',
      'p1',
      'p3',
    ].join(',');
    final sw = Stopwatch()..start();
    expect(
      await ids('Patient', {
        '_id': [many],
      }),
      ['p1', 'p3'],
    );
    sw.stop();
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(sw.elapsedMilliseconds, lessThan(2000));
    // ANDed with another condition, and counted.
    expect(
      await ids('Patient', {
        '_id': [many],
        'gender': ['female'],
      }),
      ['p1', 'p3'],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await dao.searchCount(
        resourceType: 'Patient',
        searchParameters: {
          '_id': [many],
        },
      ),
      2,
    );
    // An id holding the characters JSON and SQL quote, so the literal has
    // to be escaped twice over.
    await dao.saveResource(
      JsonNode.resource({
        'resourceType': 'Patient',
        'id': "q'uo\"te",
      }),
    );
    expect(
      await ids('Patient', {
        '_id': [
          [for (var i = 0; i < 600; i++) 'absent$i', "q'uo\"te"].join(','),
        ],
      }),
      ["q'uo\"te"],
    );
    expect(dao.lastSearchPagedInSql, isTrue);
  });

  test('a caller id set of any length is one bound JSON array, in SQL',
      () async {
    // `ids:` is fhirant's `_filter` result; over 500 it took the set path.
    final many = {for (var i = 0; i < 40000; i++) 'absent$i', 'p2', 'p3'};
    final page = await dao.search(
      resourceType: 'Patient',
      searchParameters: {
        'gender': ['female'],
      },
      ids: many,
      count: 20,
    );
    expect(page.map((r) => r.resourceId), ['p3']);
    expect(dao.lastSearchPagedInSql, isTrue);
    expect(
      await dao.searchIds(resourceType: 'Patient', ids: many),
      {'p2', 'p3'},
    );
  });
}
