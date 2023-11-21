import 'package:fhir/r4.dart';
import 'package:isar/isar.dart';

part 'resource_types.g.dart';

@collection
class ResourceTypes {
  ResourceTypes(this.resourceTypes);

  @Id()
  int id = 999;
  List<R4ResourceType> resourceTypes;
}
