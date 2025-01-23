// lib/calculator/models/medication_intake.dart

import 'package:flutter/material.dart';
import 'dosage_unit.dart';
import 'form_type.dart';
import 'administration_route.dart';
import 'intake_type.dart';

class MedicationIntake {
  final String id;
  final DateTime day;
  final String medicationId;
  final String name;
  final String dosage;
  final DosageUnit dosageUnit;
  final FormType formType;
  final AdministrationRoute administrationRoute;
  final IntakeType intakeType;
  final TimeOfDay time;

  MedicationIntake({
    required this.id,
    required this.day,
    required this.medicationId,
    required this.name,
    required this.dosage,
    required this.dosageUnit,
    required this.formType,
    required this.administrationRoute,
    required this.intakeType,
    required this.time,
  });

  /// Позволяет копировать объект с изменёнными полями
  MedicationIntake copyWith({
    String? id,
    DateTime? day,
    String? medicationId,
    String? name,
    String? dosage,
    DosageUnit? dosageUnit,
    FormType? formType,
    AdministrationRoute? administrationRoute,
    IntakeType? intakeType,
    TimeOfDay? time,
  }) {
    return MedicationIntake(
      id: id ?? this.id,
      day: day ?? this.day,
      medicationId: medicationId ?? this.medicationId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      formType: formType ?? this.formType,
      administrationRoute: administrationRoute ?? this.administrationRoute,
      intakeType: intakeType ?? this.intakeType,
      time: time ?? this.time,
    );
  }

  /// Преобразование в Map для записи в базу данных
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      // День храним в формате "YYYY-MM-DD" (убираем время)
      'day': '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}',
      'medicationId': medicationId,
      'name': name,
      'dosage': dosage,
      'dosageUnit': dosageUnit.toString().split('.').last,
      'formType': formType.toString().split('.').last,
      'administrationRoute': administrationRoute.toString().split('.').last,
      'intakeType': intakeType.toString().split('.').last,
      'time': '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
    };
  }

  /// Создание объекта из Map (чтение из базы)
  factory MedicationIntake.fromMap(Map<String, dynamic> map) {
    final dayParts = (map['day'] as String).split('-');
    final timeParts = (map['time'] as String).split(':');

    return MedicationIntake(
      id: map['id'] as String,
      day: DateTime(
        int.parse(dayParts[0]),
        int.parse(dayParts[1]),
        int.parse(dayParts[2]),
      ),
      medicationId: map['medicationId'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      dosageUnit: _dosageUnitFromString(map['dosageUnit'] as String),
      formType: _formTypeFromString(map['formType'] as String),
      administrationRoute: _administrationRouteFromString(map['administrationRoute'] as String),
      intakeType: _intakeTypeFromString(map['intakeType'] as String),
      time: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
    );
  }

  static DosageUnit _dosageUnitFromString(String value) {
    switch (value) {
      case 'mgPerKg':
        return DosageUnit.mgPerKg;
      case 'mcg':
        return DosageUnit.mcg;
      case 'g':
        return DosageUnit.g;
      default:
        return DosageUnit.mgPerKg;
    }
  }

  static FormType _formTypeFromString(String value) {
    switch (value) {
      case 'tablet':
        return FormType.tablet;
      case 'syrup':
        return FormType.syrup;
      case 'injection':
        return FormType.injection;
      default:
        return FormType.tablet;
    }
  }

  static AdministrationRoute _administrationRouteFromString(String value) {
    switch (value) {
      case 'oral':
        return AdministrationRoute.oral;
      case 'intravenous':
        return AdministrationRoute.intravenous;
      case 'intramuscular':
        return AdministrationRoute.intramuscular;
      default:
        return AdministrationRoute.oral;
    }
  }

  static IntakeType _intakeTypeFromString(String value) {
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
}
