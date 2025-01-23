// lib/calculator/models/intake_type.dart

enum IntakeType {
  morning,
  evening,
  single,
  course,
}

extension IntakeTypeExtension on IntakeType {
  String get displayName {
    switch (this) {
      case IntakeType.morning:
        return 'Утро';
      case IntakeType.evening:
        return 'Вечер';
      case IntakeType.single:
        return 'Разовый';
      case IntakeType.course:
        return 'Курс';
    }
  }
}
