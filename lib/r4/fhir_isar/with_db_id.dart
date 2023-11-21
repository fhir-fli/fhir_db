import 'package:fhir/r4.dart';
import 'package:isar/isar.dart';

Resource resourceWithDbId(Resource resource) {
  if (resource.dbId != null) {
    return resource;
  } else if (resource.fhirId != null) {
    final Map<String, dynamic> resourceMap = resource.toJson();
    resourceMap['dbId'] = Isar.fastHash(resource.fhirId!);
    return Resource.fromJson(resourceMap);
  } else {
    final Resource newResource = resource.newId();
    final Map<String, dynamic> resourceMap = newResource.toJson();
    resourceMap['dbId'] = Isar.fastHash(resource.fhirId!);
    return Resource.fromJson(resourceMap);
  }
}

Map<String, dynamic> mapWithDbId(Map<String, dynamic> map) {
  if (map['dbId'] != null) {
    return map;
  } else if (map['fhirId'] != null) {
    map['dbId'] = Isar.fastHash(map['fhirId']! as String);
    return map;
  } else {
    final Resource newResource = Resource.fromJson(map).newIdIfNoId();
    final Map<String, dynamic> resourceMap = newResource.toJson();
    resourceMap['dbId'] = Isar.fastHash(newResource.fhirId!);
    return resourceMap;
  }
}
