// lib/models/medication.dart

import 'package:flutter/material.dart';

class Medication {
  final String name;
  final String dosage;
  final TimeOfDay time;
  final IntakeType intakeType;

  Medication({
    required this.name,
    required this.dosage,
    required this.time,
    required this.intakeType,
  });
}

enum IntakeType {
  morning,
  noon,
  evening,
  night,
  single,
  course,
}

extension IntakeTypeExtension on IntakeType {
  String get displayName {
    switch (this) {
      case IntakeType.morning:
        return 'Утро';
      case IntakeType.noon:
        return 'День';
      case IntakeType.evening:
        return 'Вечер';
      case IntakeType.night:
        return 'Ночь';
      case IntakeType.single:
        return 'Единичный';
      case IntakeType.course:
        return 'Курс';
      default:
        return '';
    }
  }
}
