// lib/calculator/models/calculation_history.dart

import 'user_data.dart';

class CalculationHistory {
  final String id;
  final String medicationId;
  final String medicationName;
  final UserData userData;
  final double calculatedDose;
  final DateTime date;

  CalculationHistory({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.userData,
    required this.calculatedDose,
    required this.date,
  });

  factory CalculationHistory.fromMap(Map<String, dynamic> map) {
    return CalculationHistory(
      id: map['id'],
      medicationId: map['medicationId'],
      medicationName: map['medicationName'],
      userData: UserData.fromMap(map['userData']),
      calculatedDose: (map['calculatedDose'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'userData': userData.toMap(),
      'calculatedDose': calculatedDose,
      'date': date.toIso8601String(),
    };
  }
}
