// ignore_for_file: avoid_dynamic_calls

import 'package:fhir/r4.dart';

import 'isar_db.dart';

class FhirDbDao {
  /// Singleton factory
  factory FhirDbDao() => _fhirFhirDbDao;

  /// Private Constructor
  FhirDbDao._() {
    _fhirDb = FhirDb();
  }

  /// Singleton Accessor
  FhirDb get fhirDb => _fhirDb;

  /// The actual database
  late FhirDb _fhirDb;

  /// Singleton Instance
  static final FhirDbDao _fhirFhirDbDao = FhirDbDao._();

  /// Initalizes the database, configure its path, and return it
  FhirDb init(String? path, {String? pw}) {
    _fhirDb.initDb(path: path, encryptionKey: pw);
    return _fhirDb;
  }

  void updatepw(String? oldPw, String? newPw) =>
      _fhirDb.updateCipher(oldPw, newPw);

  void updatePw(String? oldPw, String? newPw) => updatepw(oldPw, newPw);

  /// Saves a [Resource] to the local Db, [pw] is optional (but after set,
  /// it must always be used everytime), will update the FhirFhirFhirMeta fields
  /// of the [Resource] and adds an id if none is already given.
  Resource save(
    Resource? resource, {
    String? pw,
  }) {
    if (resource != null) {
      if (resource.resourceType != null) {
        return resource.fhirId == null
            ? _insert(resource, pw)
            : fhirDb.exists(
                resourceType: resource.resourceType!,
                id: resource.fhirId!,
                encryptionKey: pw,
              )
                ? _update(resource, pw)
                : _insert(resource, pw);
      } else {
        throw const FormatException('ResourceType cannot be null');
      }
    } else {
      throw const FormatException('Resource cannot be null');
    }
  }

  /// The built-in bulkSave (called addAll) for Hive only allows automatically
  /// generated, incremented (int) IDs, so this function really just calls the
  /// save function over and over
  bool saveAll(List<Resource> resources, {String? pw}) {
    for (final Resource resource in resources) {
      try {
        save(resource, pw: pw);
      } catch (e) {
        return false;
      }
    }
    return true;
  }

  bool addAll(List<Resource> resources, {String? pw}) =>
      saveAll(resources, pw: pw);

  /// function used to save a new resource in the db
  Resource _insert(
    Resource resource,
    String? pw,
  ) {
    final Resource newResource =
        resource.newIdIfNoId().updateVersion(oldMeta: resource.meta);
    _fhirDb.save(
      resourceType: newResource.resourceType!,
      resource: newResource.toJson(),
      encryptionKey: pw,
    );
    return newResource;
  }

  /// functions used to update a resource which has already been saved into the
  /// db, will also save the old version
  Resource _update(
    Resource resource,
    String? pw,
  ) {
    if (resource.resourceTypeString != null) {
      if (resource.fhirId != null) {
        final Map<String, dynamic> dbResource = _fhirDb.get(
          resourceType: resource.resourceType!,
          id: resource.fhirId!,
          encryptionKey: pw,
        );
        if (dbResource.isNotEmpty) {
          final Map<String, dynamic> oldResource =
              Map<String, dynamic>.from(dbResource);
          _fhirDb.saveHistory(
            resource: oldResource,
            encryptionKey: pw,
          );
          final FhirMeta? oldMeta = oldResource['meta'] == null
              ? null
              : FhirMeta.fromJson(oldResource['meta'] as Map<String, dynamic>);
          final Resource newResource = resource.updateVersion(oldMeta: oldMeta);
          _fhirDb.save(
            resourceType: newResource.resourceType!,
            resource: newResource.toJson(),
            encryptionKey: pw,
          );
          return newResource;
        } else {
          return _insert(resource, pw);
        }
      } else {
        return _insert(resource, pw);
      }
    } else {
      throw const FormatException('Resource passed must have a resourceType');
    }
  }

  /// function used to save a new resource in the db
  Resource? get({
    required R4ResourceType resourceType,
    required String id,
    String? pw,
  }) {
    final Map<String, dynamic> resourceMap = _fhirDb.get(
      resourceType: resourceType,
      id: id,
      encryptionKey: pw,
    );
    return resourceMap.isEmpty
        ? null
        : Resource.fromJson(Map<String, dynamic>.from(resourceMap));
  }

  /// searches for a specific [Resource]. That resource can be defined by
  /// passing a full [Resource] object, you may pass a [resourceType] and [id]
  /// or you can pass a search [field] - since we are dealing with maps, this
  /// should be a list of strings or integers, and this function will walk
  /// through them:
  ///
  /// field = ['name', 'given', 2]
  /// newValue = resource['name'];
  /// newValue = newValue['given'];
  /// newValue = newValue[2];
  List<Resource> find({
    Resource? resource,
    R4ResourceType? resourceType,
    String? id,
    List<Object>? field,
    String? value,
    String? pw,
  }) {
    /// if we're just trying to match a resource
    if (resource != null &&
        resource.resourceType != null &&
        (resource.fhirId != null || id != null)) {
      final Map<String, dynamic> newResource = fhirDb.get(
        resourceType: resource.resourceType!,
        id: resource.fhirId!,
        encryptionKey: pw,
      );
      return newResource.isEmpty
          ? <Resource>[]
          : <Resource>[
              Resource.fromJson(Map<String, dynamic>.from(newResource))
            ];
    } else if (resourceType != null && id != null) {
      final Map<String, dynamic> newResource = fhirDb.get(
        resourceType: resourceType,
        id: id,
        encryptionKey: pw,
      );
      return newResource.isEmpty
          ? <Resource>[]
          : <Resource>[
              Resource.fromJson(Map<String, dynamic>.from(newResource))
            ];
    } else if (resourceType != null && field != null && value != null) {
      bool finder(Map<String, dynamic> finderResource) {
        dynamic result = finderResource;
        for (final Object key in field) {
          result = result[key];
        }
        return result.toString() == value;
      }

      return _search(resourceType: resourceType, finder: finder, pw: pw);
    } else {
      throw const FormatException('Must have either: '
          '\n1) a resource with a resourceType'
          '\n2) a resourceType and an Id'
          '\n3) a resourceType, a specific field, and the value of interest');
    }
  }

  /// returns all resources of a specific type
  List<Resource> getActiveResourcesOfType({
    List<R4ResourceType>? resourceTypes,
    List<String>? resourceTypeStrings,
    Resource? resource,
    String? pw,
  }) {
    final Set<R4ResourceType> typeList = <R4ResourceType>{};
    if (resource?.resourceType != null) {
      typeList.add(resource!.resourceType!);
    }
    if (resourceTypes != null && resourceTypes.isNotEmpty) {
      typeList.addAll(resourceTypes);
    }
    if (resourceTypeStrings != null) {
      for (final String type in resourceTypeStrings) {
        final R4ResourceType? resourceType = resourceTypeFromStringMap[type];
        if (resourceType != null) {
          typeList.add(resourceType);
        }
      }
    }

    final List<Resource> resourceList = <Resource>[];
    for (final R4ResourceType type in typeList) {
      final Iterable<Map<String, dynamic>> newResources =
          _fhirDb.getActiveResourcesOfType(
        resourceType: type,
        encryptionKey: pw,
      );
      resourceList.addAll(
          newResources.map((Map<String, dynamic> e) => Resource.fromJson(e)));
    }
    return resourceList;
  }

  /// returns all resources in the [db], including historical versions
  List<Resource> getAllActiveResources([String? pw]) => _fhirDb
      .getAllActiveResources(pw)
      .map((Map<String, dynamic> e) => Resource.fromJson(e))
      .toList();

  /// Delete specific resource
  bool delete({
    Resource? resource,
    R4ResourceType? resourceType,
    String? id,
    bool Function(Map<String, dynamic>)? finder,
    String? pw,
  }) {
    if (resource != null &&
        resource.resourceType != null &&
        resource.fhirId != null) {
      return _fhirDb.deleteById(
        resourceType: resource.resourceType!,
        id: resource.fhirId!,
        encryptionKey: pw,
      );
    } else if (resourceType != null && id != null) {
      return _fhirDb.deleteById(
        resourceType: resourceType,
        id: id,
        encryptionKey: pw,
      );
    } else if (resourceType != null && finder != null) {
      return _fhirDb.delete(
        resourceType: resourceType,
        finder: finder,
        encryptionKey: pw,
      );
    } else {
      throw const FormatException('Must have either: '
          '\n1) a resource with a resourceType'
          '\n2) a resourceType and an Id'
          '\n3) a resourceType, a specific field, and the value of interest');
    }
  }

  /// pass in a resourceType or a resource, and db will delete all resources of
  /// that type - Note: will NOT delete any _historical stores (must pass in
  /// _history as the type for this to happen)
  bool deleteSingleType({
    R4ResourceType? resourceType,
    Resource? resource,
    String? pw,
  }) {
    if (resourceType != null || resource?.resourceType != null) {
      resourceType ??= resource?.resourceType;
      return _fhirDb.deleteSingleType(
        resourceType: resourceType!,
        encryptionKey: pw,
      );
    }
    return false;
  }

  bool clear({String? pw}) => deleteAllResources(pw: pw);

  /// Deletes all resources, including historical versions
  bool deleteAllResources({String? pw}) => _fhirDb.deleteAllData(pw);

  /// ultimate search function, must pass in finder
  List<Resource> _search({
    required R4ResourceType resourceType,
    required bool Function(Map<String, dynamic>) finder,
    String? pw,
  }) =>
      _fhirDb
          .search(
            resourceType: resourceType,
            finder: finder,
            encryptionKey: pw,
          )
          .map((Map<String, dynamic> e) => Resource.fromJson(e))
          .toList();

  /// ************************************************************************
  /// All of the above has been for FHIR resources and data, below is if you
  /// need to store whatever else as well
  /// ************************************************************************
  bool saveGeneral({
    required Object object,
    required String key,
    String? pw,
  }) =>
      _fhirDb.saveGeneral(
        object: object,
        key: key,
        encryptionKey: pw,
      );

  Object? readGeneral({
    required String key,
    String? pw,
  }) =>
      _fhirDb.readGeneral(
        key: key,
        encryptionKey: pw,
      );

  Iterable<dynamic> getAllGeneral({String? pw}) => _fhirDb.getAllGeneral();

  Iterable<dynamic> searchGeneral({
    required bool Function(dynamic) finder,
    String? pw,
  }) =>
      _fhirDb.searchGeneral(
        finder: finder,
        encryptionKey: pw,
      );

  /// Delete specific entry
  bool deleteFromGeneral({
    required String key,
    String? pw,
  }) =>
      _fhirDb.deletefromGeneral(
        key: key,
        encryptionKey: pw,
      );

  bool clearGeneral({String? pw}) => _fhirDb.clearGeneral(pw);

  /// Deletes everything stored in the general store
  bool deleteAllGeneral({String? pw}) => _fhirDb.clearGeneral(pw);

  /// ************************************************************************
  /// These methods are for closing boxes, usually not needed and mostly for
  /// debugging purposes
  /// ************************************************************************
  void closeAllBoxes() => _fhirDb.closeAllCollections();
}
