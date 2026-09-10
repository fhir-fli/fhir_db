import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// The row builders over FhirNode, one case per shape they read. Where a
/// row's content is defined by the specification the assertion says so.
void main() {
  final model = JsonModel();
  final indexer = SearchIndexer(model);
  JsonNode node(String type, Object? value) => JsonNode(value, fhirType: type);

  group('token', () {
    test('a Coding carries system, code and normalized display', () {
      final rows = indexer.tokenRows(
        node('Coding', {
          'system': 'http://loinc.org',
          'code': '8480-6',
          'display': 'Systolic BP',
        }),
        'Observation',
        'o1',
        0,
        'Observation.code',
        0,
        searchName: 'code',
      );
      expect(rows, hasLength(1));
      expect(rows.single.tokenSystem.value, 'http://loinc.org');
      expect(rows.single.tokenValue.value, '8480-6');
      expect(rows.single.tokenDisplay.value, 'systolic bp');
    });

    test(
        'a CodeableConcept: one row per coding, and its text as a display '
        'with no code (R4B 3.1.1.4.4 :text)', () {
      final rows = indexer.tokenRows(
        node('CodeableConcept', {
          'coding': [
            {'system': 's', 'code': 'a'},
            {'system': 's', 'code': 'b'},
          ],
          'text': 'Blood pressure',
        }),
        'Observation',
        'o1',
        0,
        'Observation.code',
        2,
        searchName: 'code',
      );
      expect(rows.map((r) => r.tokenValue.value), ['a', 'b', '']);
      expect(rows.map((r) => r.paramIndex.value), [200, 201, 202]);
      expect(rows.last.tokenDisplay.value, 'blood pressure');
    });

    test('an Identifier: value, system and type.text as display', () {
      final rows = indexer.tokenRows(
        node('Identifier', {
          'system': 'urn:mrn',
          'value': '12345',
          'type': {'text': 'Medical record'},
        }),
        'Patient',
        'p1',
        0,
        'Patient.identifier',
        0,
        searchName: 'identifier',
      );
      expect(rows.single.tokenSystem.value, 'urn:mrn');
      expect(rows.single.tokenValue.value, '12345');
      expect(rows.single.tokenDisplay.value, 'medical record');
    });

    test('a code, boolean, string, id and ContactPoint each give one row', () {
      for (final (type, value, expected) in [
        ('code', 'male', 'male'),
        ('boolean', true, 'true'),
        ('string', 'x', 'x'),
        ('id', 'abc', 'abc'),
      ]) {
        final rows =
            indexer.tokenRows(node(type, value), 'Patient', 'p', 0, 'P.x', 0);
        expect(rows.single.tokenValue.value, expected, reason: type);
        expect(rows.single.tokenSystem.present, isFalse, reason: type);
      }
      final phone = indexer.tokenRows(
        node('ContactPoint', {'system': 'phone', 'value': '555-1234'}),
        'Patient',
        'p',
        0,
        'Patient.telecom',
        0,
      );
      expect(phone.single.tokenValue.value, '555-1234');
    });

    test('a CodeableReference indexes through its concept', () {
      final rows = indexer.tokenRows(
        node('CodeableReference', {
          'concept': {
            'coding': [
              {'code': 'c'},
            ],
          },
        }),
        'X',
        'x',
        0,
        'X.y',
        0,
      );
      expect(rows.single.tokenValue.value, 'c');
    });

    test('a value of another type gives no row', () {
      expect(
        indexer.tokenRows(
          node('Quantity', {'value': 1}),
          'X',
          'x',
          0,
          'X.y',
          0,
        ),
        isEmpty,
      );
    });
  });

  group('string', () {
    test(
        'a HumanName: every part, whole values on multiples of 100, one '
        'row per word (R4B 3.1.1.4.8 name parts)', () {
      final rows = indexer.stringRows(
        node('HumanName', {
          'family': 'Carreno Quinones',
          'given': ['José'],
        }),
        'Patient',
        'p1',
        0,
        'Patient.name',
        0,
        searchName: 'name',
      );
      expect(
        {for (final r in rows) r.paramIndex.value: r.stringValue.value},
        {0: 'carreno quinones', 1: 'quinones', 100: 'jose'},
      );
      expect(rows.first.exactValue.value, 'Carreno Quinones');
    });

    test('an Address: every part as a whole value', () {
      final rows = indexer.stringRows(
        node('Address', {
          'line': ['1 Main St'],
          'city': 'Springfield',
        }),
        'Patient',
        'p1',
        0,
        'Patient.address',
        0,
      );
      expect(
        rows.map((r) => r.stringValue.value),
        ['1 main st', 'springfield'],
      );
      // Whole values on the multiples of 100 (paramIndex convention).
      expect(rows.map((r) => r.paramIndex.value), [0, 100]);
    });

    test('a string under a name path is split into words; elsewhere not', () {
      final family = indexer.stringRows(
        node('string', 'Van Der Berg'),
        'Patient',
        'p',
        0,
        'Patient.name.family',
        0,
      );
      expect(family, hasLength(3));
      final other = indexer.stringRows(
        node('string', 'Van Der Berg'),
        'Observation',
        'o',
        0,
        'Observation.value',
        0,
      );
      expect(other, hasLength(1));
    });
  });

  group('reference', () {
    test('a literal reference is split into type, id, version and base', () {
      final rows = indexer.referenceRows(
        node(
          'Reference',
          {'reference': 'http://x.org/fhir/Patient/p1/_history/3'},
        ),
        'Observation',
        'o1',
        0,
        'Observation.subject',
        0,
        searchName: 'subject',
      );
      final r = rows.single;
      expect(r.referenceResourceType.value, 'Patient');
      expect(r.referenceIdPart.value, 'p1');
      expect(r.referenceVersion.value, '3');
      expect(r.referenceBaseUrl.value, 'http://x.org/fhir/');
    });

    test('an identifier-only reference keeps its identifier', () {
      final rows = indexer.referenceRows(
        node('Reference', {
          'identifier': {'system': 'urn:mrn', 'value': '1'},
        }),
        'O',
        'o',
        0,
        'O.s',
        0,
      );
      expect(rows.single.identifierSystem.value, 'urn:mrn');
      expect(rows.single.referenceValue.present, isFalse);
    });

    test('a display-only reference gives no row; a canonical gives one', () {
      expect(
        indexer.referenceRows(
          node('Reference', {'display': 'x'}),
          'O',
          'o',
          0,
          'O.s',
          0,
        ),
        isEmpty,
      );
      expect(
        indexer.referenceRows(
          node('canonical', 'http://x/StructureDefinition/y'),
          'O',
          'o',
          0,
          'O.s',
          0,
        ),
        hasLength(1),
      );
    });
  });

  group('date', () {
    test('a date covers its own precision (R4B 3.1.1.4.7)', () {
      final rows =
          indexer.dateRows(node('date', '2013-01-10'), 'P', 'p', 0, 'P.b', 0);
      expect(rows.single.dateValue.value, DateTime(2013, 1, 10));
      expect(rows.single.dateValueEnd.value, DateTime(2013, 1, 11));
      expect(rows.single.dateString.value, '2013-01-10');
    });

    test('a dateTime with an offset is an instant in UTC', () {
      final rows = indexer.dateRows(
        node('dateTime', '2013-01-14T10:00:00+02:00'),
        'P',
        'p',
        0,
        'P.b',
        0,
      );
      expect(rows.single.dateValue.value, DateTime.utc(2013, 1, 14, 8));
      expect(
        rows.single.dateValueEnd.value,
        DateTime.utc(2013, 1, 14, 8, 0, 1),
      );
    });

    test('a Period with no end is open-ended; the end is inclusive', () {
      final rows = indexer.dateRows(
        node('Period', {'start': '2013-01-01', 'end': '2013-01-10'}),
        'E',
        'e',
        0,
        'E.p',
        0,
      );
      expect(rows.single.dateValue.value, DateTime(2013));
      expect(rows.single.dateValueEnd.value, DateTime(2013, 1, 11));
      final open = indexer.dateRows(
        node('Period', {'start': '2013-01-01'}),
        'E',
        'e',
        0,
        'E.p',
        0,
      );
      expect(open.single.dateValueEnd.value, afterAnyDate);
      final noStart = indexer.dateRows(
        node('Period', {'end': '2013-01-01'}),
        'E',
        'e',
        0,
        'E.p',
        0,
      );
      expect(noStart.single.dateValue.value, beforeAnyDate);
    });

    test('a value that is not a date gives no row', () {
      expect(
        indexer.dateRows(node('dateTime', '2013-1-4'), 'P', 'p', 0, 'P.b', 0),
        isEmpty,
      );
      expect(
        indexer.dateRows(
          node('dateTime', 'yesterday'),
          'P',
          'p',
          0,
          'P.b',
          0,
        ),
        isEmpty,
      );
    });
  });

  group('quantity and number', () {
    test('a Quantity carries value, implicit range, unit, system, code', () {
      final rows = indexer.quantityRows(
        node('Quantity', {
          'value': 5.4,
          'unit': 'mg',
          'system': 'http://unitsofmeasure.org',
          'code': 'mg',
        }),
        'O',
        'o',
        0,
        'O.v',
        0,
      );
      final r = rows.single;
      expect(r.quantityValue.value, 5.4);
      expect(r.quantityLow.value, closeTo(5.35, 1e-9));
      expect(r.quantityHigh.value, closeTo(5.45, 1e-9));
      expect(r.quantityCode.value, 'mg');
    });

    test('an Age is a Quantity; a Range keeps open bounds as infinity', () {
      expect(
        indexer.quantityRows(
          node('Age', {'value': 3, 'code': 'a'}),
          'O',
          'o',
          0,
          'O.v',
          0,
        ),
        hasLength(1),
      );
      final range = indexer.quantityRows(
        node('Range', {
          'low': {'value': 1, 'unit': 'kg'},
        }),
        'O',
        'o',
        0,
        'O.v',
        0,
      );
      expect(range.single.quantityHigh.value, double.infinity);
      expect(range.single.quantityUnit.value, 'kg');
    });

    test('an integer is a point, a decimal an implicit range', () {
      final i = indexer
          .numberRows(node('integer', 100), 'O', 'o', 0, 'O.v', 0)
          .single;
      expect((i.numberLow.value, i.numberHigh.value), (100.0, 100.0));
      final d = indexer
          .numberRows(node('decimal', '100'), 'O', 'o', 0, 'O.v', 0)
          .single;
      expect((d.numberLow.value, d.numberHigh.value), (99.5, 100.5));
    });
  });

  group('uri, special, composite', () {
    test('a uri is stored as written (R4B 3.1.1.4.9)', () {
      final rows = indexer.uriRows(
        node('uri', 'HTTP://Example.org/A/'),
        'V',
        'v',
        0,
        'V.url',
        0,
      );
      expect(rows.single.uriValue.value, 'HTTP://Example.org/A/');
    });

    test('a Location.position gives a near row', () {
      final rows = indexer.specialRows(
        node('LocationPosition', {'latitude': 1.5, 'longitude': -2.25}),
        'Location',
        'l',
        0,
        'Location.position',
        0,
      );
      expect(rows.single.specialValue.value, '1.5|-2.25');
    });

    test('a composite combines its components through the typed builders', () {
      final observation = JsonNode.resource({
        'resourceType': 'Observation',
        'id': 'o1',
        'code': {
          'coding': [
            {'system': 'http://loinc.org', 'code': '8480-6'},
          ],
          'text': 'BP',
        },
        'valueQuantity': {'value': 120, 'code': 'mm[Hg]'},
      });
      final rows = indexer.compositeRows(
        observation,
        'Observation',
        'o1',
        0,
        'Observation',
        0,
        searchName: 'code-value-quantity',
        root: observation,
      );
      expect(
        rows,
        hasLength(1),
        reason: 'the text-only token row is not a value',
      );
      expect(rows.single.c1Value.value, '8480-6');
      expect(rows.single.c2Value.value, 'mm[Hg]');
      expect(rows.single.c2Low.value, 119.5);
    });
  });
}
