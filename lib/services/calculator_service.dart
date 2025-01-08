// lib/services/calculator_service.dart

import '../models/medication.dart';
import '../models/user_profile.dart';

/// Пример сервиса для расчёта дозировки и рекомендаций.
/// В данном контексте просто заглушка, чтобы не менять calendar_screen.dart.
class CalculatorService {
  double calculateDosage({
    required Medication medication,
    required UserProfile userProfile,
  }) {
    // Примитивная логика, замените реальной при необходимости
    double baseDosage =
        double.tryParse(medication.dosage.replaceAll(RegExp(r'[^0-9.]'), '')) ??
            0.0;
    if (userProfile.age > 60) {
      baseDosage *= 0.9;
    }
    return baseDosage;
  }

  bool isDosageWithinLimits(double dosage, Medication medication) {
    // Условно берём 1.2 как коэффициент
    double maxDose =
        double.tryParse(medication.dosage.replaceAll(RegExp(r'[^0-9.]'), '')) ??
            0.0;
    return dosage <= maxDose * 1.2;
  }

  List<String> generateRecommendations({
    required Medication medication,
    required double dosage,
    required UserProfile userProfile,
  }) {
    List<String> recs = [];
    // Пример рекомендаций в зависимости от вида приёма
    if (medication.intakeType == IntakeType.morning) {
      recs.add('Рекомендация: принимать натощак.');
    }
    if (dosage > 100.0) {
      recs.add('Внимание: дозировка выше 100mg.');
    }
    return recs;
  }
}
