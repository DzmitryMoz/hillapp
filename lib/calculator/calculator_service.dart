// lib/calculator/calculator_service.dart

import 'calculator_model.dart';

class CalculatorService {
  double calculateDosage({
    required Medication medication,
    required UserProfile userProfile,
  }) {
    double baseDosage = medication.dosageMg;

    // Adjust dosage based on weight (assuming 70kg as standard)
    baseDosage = baseDosage * (userProfile.weightKg / 70);

    // Adjust for age (e.g., children under 18 receive 80% of the dosage)
    if (userProfile.age < 18) {
      baseDosage *= 0.8;
    }

    // Adjust for kidney issues
    if (userProfile.hasKidneyIssues) {
      baseDosage *= 0.7;
    }

    // Adjust for liver issues
    if (userProfile.hasLiverIssues) {
      baseDosage *= 0.75;
    }

    return baseDosage;
  }

  List<String> checkInteractions(List<Medication> medications) {
    List<String> interactionWarnings = [];

    for (int i = 0; i < medications.length; i++) {
      for (int j = i + 1; j < medications.length; j++) {
        if (medications[j].interactions.contains(medications[i].name)) {
          interactionWarnings.add(
              '${medications[i].name} взаимодействует с ${medications[j].name}');
        }
      }
    }

    return interactionWarnings;
  }

  double convertUnits(double value, String fromUnit, String toUnit) {
    // Example conversion between ммоль/л и мг/дл for glucose
    if (fromUnit == 'ммоль/л' && toUnit == 'мг/дл') {
      return value * 18.0182;
    } else if (fromUnit == 'мг/дл' && toUnit == 'ммоль/л') {
      return value / 18.0182;
    }
    // Add more conversions as needed
    return value;
  }

  bool isDosageWithinLimits(double dosage, Medication medication) {
    // Define dosage limits based on medication if needed
    // For simplicity, assume dosage should not exceed 150% of base dosage
    double upperLimit = medication.dosageMg * 1.5;
    return dosage <= upperLimit;
  }
}
