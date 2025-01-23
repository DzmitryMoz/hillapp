// lib/calculator/models/calendar_medication_intake.dart

import 'package:flutter/material.dart';
import 'calendar_medication.dart';

enum IntakeType { morning, evening, single, course }

extension IntakeTypeExtension on IntakeType {
  String toShortString() => toString().split('.').last;

  static IntakeType fromString(String value) {
    switch (value) {
      case 'morning':
        return IntakeType.morning;
      case 'evening':
        return IntakeType.evening;
      case 'single':
        return IntakeType.single;
      case 'course':
        return IntakeType.course;
      default:
        return IntakeType.morning;
    }
  }

  String get displayName {
    switch (this) {
      case IntakeType.morning:
        return 'Утро';
      case IntakeType.evening:
        return 'Вечер';
      case IntakeType.single:
        return 'Одиночный';
      case IntakeType.course:
        return 'Курс';
    }
  }
}

class CalendarMedicationIntake {
  final String id;
  final String medicationId;
  final DateTime day;
  final TimeOfDay time;
  final IntakeType intakeType;

  CalendarMedicationIntake({
    required this.id,
    required this.medicationId,
    required this.day,
    required this.time,
    required this.intakeType,
  });

  factory CalendarMedicationIntake.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    return CalendarMedicationIntake(
      id: map['id'] as String,
      medicationId: map['medicationId'] as String,
      day: DateTime.parse(map['day'] as String),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      intakeType: IntakeTypeExtension.fromString(map['intakeType'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'day': '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'intakeType': intakeType.toShortString(),
    };
  }
}
