// lib/calculator/services/medication_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/medication.dart';
import '../models/dosage_unit.dart';
import '../models/form_type.dart';
import '../models/administration_route.dart';
import '../models/medication_intake.dart';
import 'database_service.dart'; // Импортируем DatabaseService

class MedicationService {
  // -- Singleton реализация --
  static final MedicationService _instance = MedicationService._internal();
  factory MedicationService() => _instance;
  MedicationService._internal();

  final DatabaseService _databaseService = DatabaseService();
  // Здесь singleton DatabaseService, но обратной ссылки из DatabaseService на MedicationService — нет

  List<Medication> _medications = [];
  List<Medication> get medications => _medications;

  Future<void> loadMedications() async {
    _medications = [];
    try {
      final dataString =
      await rootBundle.loadString('assets/calculator/data/medications.json');
      final List<dynamic> data = json.decode(dataString);
      _medications = data.map((item) {
        return Medication(
          id: item['id'] as String,
          name: item['name'] as String,
          description: item['description'] as String? ?? '',
          standardDosePerKg:
          (item['standardDosePerKg'] as num?)?.toDouble() ?? 0.0,
          maxDose: (item['maxDose'] as num?)?.toDouble() ?? 0.0,
          minAge: (item['minAge'] as num?)?.toDouble() ?? 0.0,
          maxAge: (item['maxAge'] as num?)?.toDouble() ?? 0.0,
          dosageUnit: _dosageUnitFromString(item['dosageUnit'] as String),
          formType: _formTypeFromString(item['formType'] as String),
          administrationRoute:
          _administrationRouteFromString(item['administrationRoute'] as String),
        );
      }).toList();
    } catch (_) {
      _medications = [];
    }
  }

  void addManualMedication(Medication medication) {
    _medications.add(medication);
    // Сохраняем в БД через DatabaseService
    _databaseService.insertMedication(medication);
  }

  Medication? getMedicationByName(String name) {
    try {
      return _medications.firstWhere(
            (m) => m.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Возвращает приёмы (MedicationIntake) на конкретный день
  Future<List<MedicationIntake>> getMedicationsForDay(DateTime day) async {
    return await _databaseService.getMedicationsForDay(day);
  }

  // -- Преобразование строк -> enum (локально, только для загрузки JSON) --
  DosageUnit _dosageUnitFromString(String value) {
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

  FormType _formTypeFromString(String value) {
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

  AdministrationRoute _administrationRouteFromString(String value) {
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
}
