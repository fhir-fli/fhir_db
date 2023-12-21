// ignore_for_file: avoid_print

import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fhir/r4.dart';
import 'package:fhir_bulk/r4.dart';
import 'package:fhir_db/r4/fhir_isar/fhir_isar.dart';
import 'package:test/test.dart';

import 'test_resources.dart';

Future<void> main() async {
  const String directory = 'db';
  if (Directory(directory).existsSync()) {
    await Directory(directory).delete(recursive: true);
  }

  /// Initialize Hive & Clear Current Hive DB
  final IsarDbDao fhirDbDao = IsarDbDao();
  // const String password1 = 'password1';
  const String password2 = 'password2';
  fhirDbDao.init(directory, pw: password2);
  const Patient patient1 = Patient(fhirId: '1');
  final Resource saved1 = fhirDbDao.save(patient1, pw: password2);
  group('', () {
    test('Saved A Patient, Found A Patient', () {
      final List<Resource> search1 = fhirDbDao.find(
          resourceType: R4ResourceType.Patient, id: '1', pw: password2);
      expect(saved1, search1[0]);
    });

    test('Found Patient With New Password Because Box Was Already Opened', () {
      final List<Resource> search2 = fhirDbDao.find(
          resourceType: R4ResourceType.Patient, id: '1', pw: password2);
      expect(saved1, search2[0]);
    });

    // test('Password Changed', () {
    //   fhirDbDao.updatePw(password1, password2);
    //   // final List<Resource> search3 =  fhirDbDao.find(password1,
    //   //     resourceType: R4ResourceType.Patient, id: '1');
    //   // expect(true, search3.isEmpty);
    //   //  fhirDbDao.closeAllBoxes();
    //   final List<Resource> search4 = fhirDbDao.find(
    //       resourceType: R4ResourceType.Patient, id: '1', pw: password2);
    //   expect(saved1, search4[0]);
    //   fhirDbDao.updatePw(password2, null);
    // });
  });

  const String id = '12345';
  group('Saving Things:', () {
    test('Save Patient', () {
      const HumanName humanName =
          HumanName(family: 'Atreides', given: <String>['Duke']);
      const Patient patient = Patient(fhirId: id, name: <HumanName>[humanName]);
      final Resource saved = fhirDbDao.save(patient);

      expect(saved.fhirId, id);
      expect((saved as Patient).name?[0], humanName);
    });

    test('Save Organization', () {
      const Organization organization =
          Organization(fhirId: id, name: 'FhirFli');
      final Resource saved = fhirDbDao.save(organization);

      expect(saved.fhirId, id);

      expect((saved as Organization).name, 'FhirFli');
    });

    test('Save Observation1', () {
      final Observation observation1 = Observation(
        fhirId: 'obs1',
        code: const CodeableConcept(text: 'Observation #1'),
        effectiveDateTime: FhirDateTime(DateTime(1981, 09, 18)),
      );
      final Resource saved = fhirDbDao.save(observation1);

      expect(saved.fhirId, 'obs1');

      expect((saved as Observation).code.text, 'Observation #1');
    });

    test('Save Observation1 Again', () {
      const Observation observation1 = Observation(
          fhirId: 'obs1',
          code: CodeableConcept(text: 'Observation #1 - Updated'));
      final Resource saved = fhirDbDao.save(observation1);

      expect(saved.fhirId, 'obs1');

      expect((saved as Observation).code.text, 'Observation #1 - Updated');

      expect(saved.meta?.versionId, FhirId('2'));
    });

    test('Save Observation2', () {
      final Observation observation2 = Observation(
        fhirId: 'obs2',
        code: const CodeableConcept(text: 'Observation #2'),
        effectiveDateTime: FhirDateTime(DateTime(1981, 09, 18)),
      );
      final Resource saved = fhirDbDao.save(observation2);

      expect(saved.fhirId, 'obs2');

      expect((saved as Observation).code.text, 'Observation #2');
    });

    test('Save Observation3', () {
      final Observation observation3 = Observation(
        fhirId: 'obs3',
        code: const CodeableConcept(text: 'Observation #3'),
        effectiveDateTime: FhirDateTime(DateTime(1981, 09, 18)),
      );
      final Resource saved = fhirDbDao.save(observation3);

      expect(saved.fhirId, 'obs3');

      expect((saved as Observation).code.text, 'Observation #3');
    });
  });

  group('Finding Things:', () {
    test('Find 1st Patient', () {
      final List<Resource> search =
          fhirDbDao.find(resourceType: R4ResourceType.Patient, id: id);
      const HumanName humanName =
          HumanName(family: 'Atreides', given: <String>['Duke']);

      expect(search.length, 1);

      expect((search[0] as Patient).name?[0], humanName);
    });

    test('Find 3rd Observation', () {
      final List<Resource> search =
          fhirDbDao.find(resourceType: R4ResourceType.Observation, id: 'obs3');

      expect(search.length, 1);

      expect(search[0].fhirId, 'obs3');

      expect((search[0] as Observation).code.text, 'Observation #3');
    });

    test('Find All Observations', () {
      final List<Resource> search = fhirDbDao.getActiveResourcesOfType(
        resourceTypes: <R4ResourceType>[R4ResourceType.Observation],
      );

      expect(search.length, 3);

      final List<String> idList = <String>[];
      for (final Resource obs in search) {
        idList.add(obs.fhirId.toString());
      }

      expect(idList.contains('obs1'), true);

      expect(idList.contains('obs2'), true);

      expect(idList.contains('obs3'), true);
    });

    test('Find All (non-historical) Resources', () {
      final List<Resource> search = fhirDbDao.getAllActiveResources();

      expect(search.length, 6);
      final List<Resource> patList = search.toList();
      final List<Resource> orgList = search.toList();
      final List<Resource> obsList = search.toList();
      patList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Patient);
      orgList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Organization);
      obsList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Observation);

      expect(patList.length, 2);

      expect(orgList.length, 1);

      expect(obsList.length, 3);
    });
  });

  group('Deleting Things:', () {
    test('Delete 2nd Observation', () {
      fhirDbDao.delete(
        resourceType: R4ResourceType.Observation,
        id: 'obs2',
      );

      final List<Resource> search = fhirDbDao.getActiveResourcesOfType(
        resourceTypes: <R4ResourceType>[R4ResourceType.Observation],
      );

      expect(search.length, 2);

      final List<String> idList = <String>[];
      for (final Resource obs in search) {
        idList.add(obs.fhirId.toString());
      }

      expect(idList.contains('obs1'), true);

      expect(idList.contains('obs2'), false);

      expect(idList.contains('obs3'), true);
    });

    test('Delete All Observations', () {
      fhirDbDao.deleteSingleType(resourceType: R4ResourceType.Observation);

      final List<Resource> search = fhirDbDao.getAllActiveResources();

      expect(search.length, 3);

      final List<Resource> patList = search.toList();
      final List<Resource> orgList = search.toList();
      patList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Patient);
      orgList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Organization);

      expect(patList.length, 2);
    });

    test('Delete All Resources', () {
      fhirDbDao.deleteAllResources();

      final List<Resource> search = fhirDbDao.getAllActiveResources();

      expect(search.length, 0);
    });
  });

  group('Password - Saving Things:', () {
    test('Save Patient', () {
      fhirDbDao.updatePw(null, password2);
      const HumanName humanName =
          HumanName(family: 'Atreides', given: <String>['Duke']);
      const Patient patient = Patient(fhirId: id, name: <HumanName>[humanName]);
      final Resource saved = fhirDbDao.save(patient, pw: password2);

      expect(saved.fhirId, id);

      expect((saved as Patient).name?[0], humanName);
    });

    test('Save Organization', () {
      const Organization organization =
          Organization(fhirId: id, name: 'FhirFli');
      final Resource saved = fhirDbDao.save(organization, pw: password2);

      expect(saved.fhirId, id);

      expect((saved as Organization).name, 'FhirFli');
    });

    test('Save Observation1', () {
      final Observation observation1 = Observation(
        fhirId: 'obs1',
        code: const CodeableConcept(text: 'Observation #1'),
        effectiveDateTime: FhirDateTime(DateTime(1981, 09, 18)),
      );
      final Resource saved = fhirDbDao.save(observation1, pw: password2);

      expect(saved.fhirId, 'obs1');

      expect((saved as Observation).code.text, 'Observation #1');
    });

    test('Save Observation1 Again', () {
      const Observation observation1 = Observation(
          fhirId: 'obs1',
          code: CodeableConcept(text: 'Observation #1 - Updated'));
      final Resource saved = fhirDbDao.save(observation1, pw: password2);

      expect(saved.fhirId, 'obs1');

      expect((saved as Observation).code.text, 'Observation #1 - Updated');

      expect(saved.meta?.versionId, FhirId('2'));
    });

    test('Save Observation2', () {
      final Observation observation2 = Observation(
        fhirId: 'obs2',
        code: const CodeableConcept(text: 'Observation #2'),
        effectiveDateTime: FhirDateTime(DateTime(1981, 09, 18)),
      );
      final Resource saved = fhirDbDao.save(observation2, pw: password2);

      expect(saved.fhirId, 'obs2');

      expect((saved as Observation).code.text, 'Observation #2');
    });

    test('Save Observation3', () {
      final Observation observation3 = Observation(
        fhirId: 'obs3',
        code: const CodeableConcept(text: 'Observation #3'),
        effectiveDateTime: FhirDateTime(DateTime(1981, 09, 18)),
      );
      final Resource saved = fhirDbDao.save(observation3, pw: password2);

      expect(saved.fhirId, 'obs3');

      expect((saved as Observation).code.text, 'Observation #3');
    });
  });

  group('Password - Finding Things:', () {
    test('Find 1st Patient', () {
      final List<Resource> search = fhirDbDao.find(
          resourceType: R4ResourceType.Patient, id: id, pw: password2);
      const HumanName humanName =
          HumanName(family: 'Atreides', given: <String>['Duke']);

      expect(search.length, 1);

      expect((search[0] as Patient).name?[0], humanName);
    });

    test('Find 3rd Observation', () {
      final List<Resource> search = fhirDbDao.find(
          resourceType: R4ResourceType.Observation, id: 'obs3', pw: password2);

      expect(search.length, 1);

      expect(search[0].fhirId, 'obs3');

      expect((search[0] as Observation).code.text, 'Observation #3');
    });

    test('Find All Observations', () {
      final List<Resource> search = fhirDbDao.getActiveResourcesOfType(
          resourceTypes: <R4ResourceType>[R4ResourceType.Observation],
          pw: password2);

      expect(search.length, 3);

      final List<String> idList = <String>[];
      for (final Resource obs in search) {
        idList.add(obs.fhirId.toString());
      }

      expect(idList.contains('obs1'), true);

      expect(idList.contains('obs2'), true);

      expect(idList.contains('obs3'), true);
    });

    test('Find All (non-historical) Resources', () {
      final List<Resource> search = fhirDbDao.getAllActiveResources(password2);

      expect(search.length, 5);
      final List<Resource> patList = search.toList();
      final List<Resource> orgList = search.toList();
      final List<Resource> obsList = search.toList();
      patList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Patient);
      orgList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Organization);
      obsList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Observation);

      expect(patList.length, 1);

      expect(orgList.length, 1);

      expect(obsList.length, 3);
    });
  });

  group('Password - Deleting Things:', () {
    test('Delete 2nd Observation', () {
      fhirDbDao.delete(resourceType: R4ResourceType.Observation, id: 'obs2');

      final List<Resource> search = fhirDbDao.getActiveResourcesOfType(
          resourceTypes: <R4ResourceType>[R4ResourceType.Observation],
          pw: password2);

      expect(search.length, 2);

      final List<String> idList = <String>[];
      for (final Resource obs in search) {
        idList.add(obs.fhirId.toString());
      }

      expect(idList.contains('obs1'), true);

      expect(idList.contains('obs2'), false);

      expect(idList.contains('obs3'), true);
    });

    test('Delete All Observations', () {
      fhirDbDao.deleteSingleType(resourceType: R4ResourceType.Observation);

      final List<Resource> search = fhirDbDao.getAllActiveResources(password2);

      expect(search.length, 2);

      final List<Resource> patList = search.toList();
      final List<Resource> orgList = search.toList();
      patList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Patient);
      orgList.retainWhere((Resource resource) =>
          resource.resourceType == R4ResourceType.Organization);

      expect(patList.length, 1);

      expect(patList.length, 1);
    });

    test('Delete All Resources', () {
      fhirDbDao.deleteAllResources(pw: password2);

      final List<Resource> search = fhirDbDao.getAllActiveResources(password2);

      expect(search.length, 0);

      fhirDbDao.updatePw(password2, null);
    });
  });

  group('More Complicated Searching', () {
    test('(& Resources)', () async {
      String output = '';
      final fileList = [
        'Condition.ndjson',
        'Encounter.ndjson',
        'EncounterICU.ndjson',
        'Location.ndjson',
        'Medication.ndjson',
        'MedicationAdministration.ndjson',
        'MedicationAdministrationICU.ndjson',
        'MedicationDispense.ndjson',
        'MedicationRequest.ndjson',
        'ObservationChartevents.ndjson',
        'ObservationDatetimeevents.ndjson',
        'ObservationLabevents.ndjson',
        'ObservationMicroOrg.ndjson',
        'ObservationMicroSusc.ndjson',
        'ObservationMicroTest.ndjson',
        'Organization.ndjson',
        'Patient.ndjson',
        'Procedure.ndjson',
        'ProcedureICU.ndjson',
        'Specimen.ndjson',
        'SpecimenLab.ndjson',
      ];

      int total = 0;
      const int numberOfTimes = 1;
      for (int i = 0; i < numberOfTimes; i++) {
        final DateTime startTime = DateTime.now();
        for (final String file in fileList) {
          // print(file);
          int i = 0;
          final List<Resource> resources =
              await FhirBulk.fromFile('assets/$file');
          for (final Resource? resource in resources) {
            if (resource != null) {
              i++;
              fhirDbDao.save(resource);
            }
          }
          total += i;
        }
        final DateTime endTime = DateTime.now();
        final Duration duration = endTime.difference(startTime);
        output += 'Total Resources: $total\n';
        output += 'Total time: ${duration.inSeconds} seconds';
      }
      fhirDbDao.save(testPatient1);
      fhirDbDao.save(testPatient2);
      fhirDbDao.save(testObservation1);
      fhirDbDao.save(testObservation2);
      fhirDbDao.save(testObservation3);
      fhirDbDao.save(testObservation4);
      fhirDbDao.save(testObservation5);
      fhirDbDao.save(testObservation6);
      fhirDbDao.save(testConceptMap1);
      fhirDbDao.save(testCondition1);

      print(output);
      final DateTime testStartTime = DateTime.now();
      expect(true, compareTwoResources(testPatient1, fhirDbDao, null));
      expect(true, compareTwoResources(testPatient2, fhirDbDao, null));
      expect(true, compareTwoResources(testObservation1, fhirDbDao, null));
      expect(true, compareTwoResources(testObservation2, fhirDbDao, null));
      expect(true, compareTwoResources(testObservation3, fhirDbDao, null));
      expect(true, compareTwoResources(testObservation4, fhirDbDao, null));
      expect(true, compareTwoResources(testObservation5, fhirDbDao, null));
      expect(true, compareTwoResources(testObservation6, fhirDbDao, null));
      expect(true, compareTwoResources(testConceptMap1, fhirDbDao, null));
      expect(true, compareTwoResources(testCondition1, fhirDbDao, null));
      final DateTime testEndTime = DateTime.now();
      print(
          'Found 10 resources in total of ${testEndTime.difference(testStartTime).inMilliseconds} ms');
    }, timeout: const Timeout(Duration(minutes: 10)));
  });
}

bool compareTwoResources(
    Resource originalResource, IsarDbDao fhirDbDao, String? pw) {
  final Resource? dbResource = fhirDbDao.get(
      pw: pw,
      resourceType: originalResource.resourceType!,
      id: originalResource.fhirId!);
  final Map<String, dynamic> resource1Json = originalResource.toJson();
  final Map<String, dynamic>? resource2json = dbResource?.toJson();
  resource1Json.remove('meta');
  resource2json?.remove('meta');
  if (!(const DeepCollectionEquality()).equals(resource1Json, resource2json)) {
    return false;
  }
  if (!(const DeepCollectionEquality()).equals(resource2json, resource1Json)) {
    return false;
  }
  return true;
}
