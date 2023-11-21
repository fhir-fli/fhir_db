// ignore_for_file: avoid_dynamic_calls

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:fhir/r4/resource/resource.dart';
import 'package:isar/isar.dart';

import 'fhir_isar.dart';

class FhirDb {
  Isar? _isar;

  Future<void> updateCipher(
      String? oldEncryptionKey, String? newEncryptionKey) async {
    /// only both to change things if the new password doesn't equal the old password
    if (oldEncryptionKey != newEncryptionKey) {
      initDb(encryptionKey: oldEncryptionKey);
      _isar!.copyToFile('.');
    }
  }

  /// To initialize the database as a whole. Configure the path, set initialized
  /// to true, register all of the ResourceTypeAdapters, and then assign the
  /// set of all of the types to the variable types
  void initDb({String? path, String? encryptionKey}) {
    if (!(_isar?.isOpen ?? false)) {
      _isar = Isar.open(
        schemas: <IsarGeneratedSchema>[
          ...resourceSchemas,
          ResourceTypesSchema,
          HistoryResourceSchema,
          IsarGeneralsSchema,
        ],
        directory: path ?? '.',
        encryptionKey: encryptionKey,
      );
    }
  }

  /// This is to get a specific Collection
  IsarCollection<int, IsarResource> _getCollection(
      {required R4ResourceType resourceType, String? encryptionKey}) {
    initDb(encryptionKey: encryptionKey);
    return _isar!.resourceTypeToIsarType(resourceType);
  }

  /// In this case we're adding a type. If it's already included, we just
  /// return true and don't re-add it. Otherwise we enseure db is initialized,
  /// and after we can assume the 'types' collection is open, get the Set, update
  /// it, write it back, and return true.
  bool _addType({
    required R4ResourceType resourceType,
    String? encryptionKey,
  }) {
    try {
      initDb(encryptionKey: encryptionKey);
      final ResourceTypes? types = _isar!.resourceTypes.get(999);
      if (types == null) {
        _isar!.resourceTypes.put(ResourceTypes(<R4ResourceType>[resourceType]));
        return true;
      } else if (types.resourceTypes.contains(resourceType)) {
        return true;
      } else {
        types.resourceTypes.add(resourceType);
        _isar!.resourceTypes.put(types);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  bool save({
    required R4ResourceType resourceType,
    required Map<String, dynamic> resource,
    String? encryptionKey,
  }) {
    try {
      initDb(encryptionKey: encryptionKey);
      _getCollection(resourceType: resourceType, encryptionKey: encryptionKey)
          .put(mapToIsarResource(resource));
      return _addType(resourceType: resourceType, encryptionKey: encryptionKey);
    } catch (e, s) {
      log('Error: $e, Stack at time of Error: $s');
      return false;
    }
  }

  bool saveHistory(
      {required Map<String, dynamic> resource, String? encryptionKey}) {
    try {
      initDb(encryptionKey: encryptionKey);
      resource['dbId'] = Isar.fastHash(
          '${resource["resourceType"]}/${resource["id"]}/${resource["meta"]?["versionId"]}');
      _isar!.historyResources.put(
          HistoryResource(id: resource['dbId'] as int, resource: resource));
      return true;
    } catch (e, s) {
      log('Error: $e, Stack at time of Error: $s');
      return false;
    }
  }

  bool exists({
    required R4ResourceType resourceType,
    required String id,
    String? encryptionKey,
  }) {
    initDb(encryptionKey: encryptionKey);
    final ResourceTypes? resourceTypes = _isar!.resourceTypes.get(999);
    if (resourceTypes == null ||
        !resourceTypes.resourceTypes.contains(resourceType)) {
      return false;
    } else {
      final IsarCollection<int, IsarResource> collection = _getCollection(
          resourceType: resourceType, encryptionKey: encryptionKey);
      final IsarResource? match = collection.get(Isar.fastHash(id));

      if (match == null) {
        final List<IsarAccount> matches =
            _isar!.isarAccounts.where().fhirIdEqualTo(id).findAll();
        if (matches.isEmpty) {
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    }
  }

  Map<String, dynamic> get({
    required R4ResourceType resourceType,
    required String id,
    String? encryptionKey,
  }) {
    initDb(encryptionKey: encryptionKey);
    final IsarCollection<int, IsarResource> collection = _getCollection(
        resourceType: resourceType, encryptionKey: encryptionKey);
    try {
      final IsarResource? match = collection.get(Isar.fastHash(id));
      if (match != null) {
        return match.resource;
      } else {
        final List<IsarAccount> matches =
            _isar!.isarAccounts.where().fhirIdEqualTo(id).findAll();
        if (matches.isEmpty) {
          return <String, dynamic>{};
        } else {
          return matches.first.resource;
        }
      }
    } catch (e, s) {
      print(e);
      print(s);
      return <String, dynamic>{};
    }
  }

  Iterable<Map<String, dynamic>> getActiveResourcesOfType(
      {required R4ResourceType resourceType, String? encryptionKey}) {
    initDb(encryptionKey: encryptionKey);
    final IsarCollection<int, IsarResource> collection = _getCollection(
        resourceType: resourceType, encryptionKey: encryptionKey);
    return collection
        .where()
        .findAll()
        .map((IsarResource e) => e.resource)
        .toList();
  }

  List<Map<String, dynamic>> getAllActiveResources([String? encryptionKey]) {
    initDb(encryptionKey: encryptionKey);
    final List<Map<String, dynamic>> allResources = <Map<String, dynamic>>[];
    for (final R4ResourceType type
        in _isar!.resourceTypes.get(999)!.resourceTypes) {
      allResources.addAll(getActiveResourcesOfType(
          resourceType: type, encryptionKey: encryptionKey));
    }
    return allResources;
  }

  bool deleteById({
    required R4ResourceType resourceType,
    required String id,
    String? encryptionKey,
  }) {
    try {
      initDb(encryptionKey: encryptionKey);
      final IsarCollection<int, IsarResource> collection = _getCollection(
        resourceType: resourceType,
        encryptionKey: encryptionKey,
      );
      return collection.delete(Isar.fastHash(id));
    } catch (e) {
      return false;
    }
  }

  bool delete({
    required R4ResourceType resourceType,
    required bool Function(Map<String, dynamic>) finder,
    String? encryptionKey,
  }) {
    try {
      initDb(encryptionKey: encryptionKey);
      final IsarCollection<int, IsarResource> collection = _getCollection(
          resourceType: resourceType, encryptionKey: encryptionKey);
      final Iterable<IsarResource> resources = collection
          .where()
          .findAll()
          .toList()
          .where((IsarResource isarResource) =>
              finder(Map<String, dynamic>.from(isarResource.resource)));
      if (resources.isNotEmpty) {
        for (final IsarResource resource in resources) {
          collection.delete(resource.id);
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  bool deleteSingleType(
      {required R4ResourceType resourceType, String? encryptionKey}) {
    try {
      initDb(encryptionKey: encryptionKey);
      final IsarCollection<int, IsarResource> collection = _getCollection(
        resourceType: resourceType,
        encryptionKey: encryptionKey,
      );
      collection.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  bool deleteAllData([String? encryptionKey]) {
    try {
      initDb(encryptionKey: encryptionKey);
      _isar!.clear();
      _isar!.close(deleteFromDisk: true);
      return true;
    } catch (e) {
      return false;
    }
  }

  bool deleteDatabase([String? encryptionKey]) {
    return deleteAllData(encryptionKey);
  }

  Iterable<Map<String, dynamic>> search({
    required R4ResourceType resourceType,
    required bool Function(Map<String, dynamic>) finder,
    String? encryptionKey,
  }) {
    initDb(encryptionKey: encryptionKey);
    final IsarCollection<int, IsarResource> collection = _getCollection(
        resourceType: resourceType, encryptionKey: encryptionKey);
    final List<IsarResource> collectionData = collection.where().findAll();
    collectionData.removeWhere((IsarResource isarResource) =>
        !finder(Map<String, dynamic>.from(isarResource.resource)));
    return collectionData
        .map((IsarResource isarResource) =>
            jsonDecode(jsonEncode(isarResource.resource))
                as Map<String, dynamic>)
        .toList();
  }

  /// ************************************************************************
  /// All of the above has been for FHIR resources and data, below is if you
  /// need to store whatever else as well
  /// ************************************************************************

  bool saveGeneral(
      {required Object object, required String key, String? encryptionKey}) {
    initDb(encryptionKey: encryptionKey);
    try {
      _isar!.isarGenerals.put(IsarGenerals(name: key, value: object));
      return true;
    } catch (e) {
      return false;
    }
  }

  Object? readGeneral({required String key, String? encryptionKey}) {
    initDb(encryptionKey: encryptionKey);
    return _isar!.isarGenerals.get(Isar.fastHash(key))?.value;
  }

  Iterable<dynamic> getAllGeneral([String? encryptionKey]) {
    initDb(encryptionKey: encryptionKey);
    return _isar!.isarGenerals
        .where()
        .findAll()
        .map((IsarGenerals isarGenerals) => isarGenerals.value)
        .toList();
  }

  Iterable<dynamic> searchGeneral({
    required bool Function(dynamic) finder,
    String? encryptionKey,
  }) {
    initDb(encryptionKey: encryptionKey);
    final List<dynamic> collectionData = _isar!.isarGenerals
        .where()
        .findAll()
        .map((IsarGenerals isarGenerals) => isarGenerals.value)
        .toList();
    collectionData.removeWhere((dynamic value) => !finder(value));
    return collectionData;
  }

  bool deletefromGeneral({required String key, String? encryptionKey}) {
    initDb(encryptionKey: encryptionKey);
    try {
      _isar!.isarGenerals.delete(Isar.fastHash(key));
      return true;
    } catch (e) {
      return false;
    }
  }

  bool clearGeneral([String? encryptionKey]) {
    initDb(encryptionKey: encryptionKey);
    try {
      _isar!.isarGenerals.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// ************************************************************************
  /// These methods are for closing collections, usually not needed and mostly for
  /// debugging purposes
  /// ************************************************************************
  void closeAllCollections() =>
      (_isar?.isOpen ?? false) ? _isar!.close() : null;
}
