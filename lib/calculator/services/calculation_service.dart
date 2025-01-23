// lib/calculator/services/calculation_service.dart

import '../models/medication.dart';

class CalculationService {
  double calculateDose(Medication medication, double weight) {
    return medication.standardDosePerKg * weight;
  }
}