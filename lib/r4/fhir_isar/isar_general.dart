import 'package:isar/isar.dart';

part 'isar_general.g.dart';

@collection
class IsarGenerals {
  IsarGenerals({required this.name, required this.value})
      : id = Isar.fastHash(name);

  @Id()
  late int id;

  @Index()
  String name;

  dynamic value;
}
