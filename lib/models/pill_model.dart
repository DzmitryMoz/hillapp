// lib/models/pill_model.dart
import 'package:hive/hive.dart';

part 'pill_model.g.dart';

@HiveType(typeId: 0)
enum PillType {
  @HiveField(0)
  single,
  @HiveField(1)
  course,
  @HiveField(2)
  morning,
  @HiveField(3)
  evening,
}

@HiveType(typeId: 1)
class PillModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double dose;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  PillType type;

  PillModel({
    required this.name,
    required this.dose,
    required this.date,
    required this.type,
  });
}
