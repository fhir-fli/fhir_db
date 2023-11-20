import 'package:fhir/r4.dart';

/// FNV-1a 64bit hash algorithm optimized for Dart Strings
int fastHash(String string) {
  int hash = 0xcbf29ce484222325;

  int i = 0;
  while (i < string.length) {
    final int codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }

  return hash;
}

Resource withDbId(Resource resource) {
  if (resource.dbId != null) {
    return resource;
  } else if (resource.fhirId != null) {
    final Map<String, dynamic> resourceMap = resource.toJson();
    resourceMap['dbId'] = fastHash(resource.fhirId!);
    return Resource.fromJson(resourceMap);
  } else {
    final Resource newResource = resource.newId();
    final Map<String, dynamic> resourceMap = newResource.toJson();
    resourceMap['dbId'] = fastHash(newResource.fhirId!);
    return Resource.fromJson(resourceMap);
  }
}
