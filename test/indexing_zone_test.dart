import 'dart:async';

import 'package:drift/native.dart';
import 'package:fhir_db/fhir_db.dart';
import 'package:test/test.dart';

import 'support/json_node.dart';

/// A background re-index started from a zone whose microtasks never run
/// (a widget test's zone between pumps) must not stop the store closing:
/// `close()` waits for the run, and the run's end was delivered through
/// the starting zone's microtask queue (fhirant administration screen
/// test, every fhir_db 0.16 release up to 0.16.3, measured 2026-11-26).
void main() {
  test('close is not held by the zone a run was started from', () async {
    final db = FhirDb(NativeDatabase.memory(), model: JsonModel());
    await db.customSelect('SELECT 1').get();
    final held = <void Function()>[];
    runZoned(
      db.searchParameterIndexing.resume,
      zoneSpecification: ZoneSpecification(
        scheduleMicrotask: (self, parent, zone, f) => held.add(f),
      ),
    );
    await db.close().timeout(
          const Duration(seconds: 10),
          onTimeout: () => fail('close waited for the held zone'),
        );
    expect(held, isEmpty, reason: 'nothing of the run waits there');
  });
}
