// lib/calendar/models/calendar_medication_intake.dart

import 'package:flutter/material.dart';

/// Тип приёма, например: утро, вечер, одиночный, курс
enum IntakeType { morning, evening, single, course }

/// Расширение для вывода русского названия
extension IntakeTypeExtension on IntakeType {
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

/// Модель CalendarMedicationIntake
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

  Map<String, dynamic> toMap() {
    // Например, для сохранения в БД
    return {
      'id': id,
      'medicationId': medicationId,
      'day':
      '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
      'time':
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
      'intakeType': intakeType.toString().split('.').last,
    };
  }

  factory CalendarMedicationIntake.fromMap(Map<String, dynamic> map) {
    final timeParts = (map['time'] as String).split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    return CalendarMedicationIntake(
      id: map['id'] as String,
      medicationId: map['medicationId'] as String,
      day: DateTime.parse(map['day'] as String),
      time: TimeOfDay(hour: hour, minute: minute),
      intakeType: _intakeTypeFromString(map['intakeType'] as String),
    );
  }

  /// copyWith
  CalendarMedicationIntake copyWith({
    DateTime? day,
    TimeOfDay? time,
    IntakeType? intakeType,
  }) {
    return CalendarMedicationIntake(
      id: id,
      medicationId: medicationId,
      day: day ?? this.day,
      time: time ?? this.time,
      intakeType: intakeType ?? this.intakeType,
    );
  }

  static IntakeType _intakeTypeFromString(String value) {
    return IntakeType.values.firstWhere(
          (e) => e.toString().split('.').last == value,
      orElse: () => IntakeType.morning,
    );
  }
}
