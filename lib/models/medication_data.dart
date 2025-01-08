// lib/models/medication_data.dart

import 'package:flutter/material.dart';
import 'medication.dart';

class MedicationData {
  static final MedicationData _instance = MedicationData._internal();

  factory MedicationData() => _instance;

  MedicationData._internal();

  final Map<DateTime, List<Medication>> _medications = {};

  List<Medication> getMedications(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _medications[date] ?? [];
  }

  void addMedication(DateTime day, Medication medication) {
    final date = DateTime(day.year, day.month, day.day);
    if (_medications.containsKey(date)) {
      _medications[date]!.add(medication);
    } else {
      _medications[date] = [medication];
    }
  }
}
