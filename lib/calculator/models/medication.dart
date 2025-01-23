// lib/calculator/models/medication.dart

import 'dosage_unit.dart';
import 'form_type.dart';
import 'administration_route.dart';

class Medication {
  final String id;
  final String name;
  final String description;
  final double standardDosePerKg;
  final double maxDose;
  final double minAge;
  final double maxAge;
  final DosageUnit dosageUnit;
  final FormType formType;
  final AdministrationRoute administrationRoute;

  Medication({
    required this.id,
    required this.name,
    required this.description,
    required this.standardDosePerKg,
    required this.maxDose,
    required this.minAge,
    required this.maxAge,
    required this.dosageUnit,
    required this.formType,
    required this.administrationRoute,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'standardDosePerKg': standardDosePerKg,
      'maxDose': maxDose,
      'minAge': minAge,
      'maxAge': maxAge,
      'dosageUnit': dosageUnit.toString().split('.').last,
      'formType': formType.toString().split('.').last,
      'administrationRoute': administrationRoute.toString().split('.').last,
    };
  }

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      standardDosePerKg: (map['standardDosePerKg'] as num).toDouble(),
      maxDose: (map['maxDose'] as num).toDouble(),
      minAge: (map['minAge'] as num).toDouble(),
      maxAge: (map['maxAge'] as num).toDouble(),
      dosageUnit: DosageUnit.values.firstWhere(
              (e) => e.toString().split('.').last == map['dosageUnit']),
      formType: FormType.values.firstWhere(
              (e) => e.toString().split('.').last == map['formType']),
      administrationRoute: AdministrationRoute.values.firstWhere(
              (e) => e.toString().split('.').last == map['administrationRoute']),
    );
  }
}
