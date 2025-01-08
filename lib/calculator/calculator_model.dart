// lib/calculator/calculator_model.dart

class Medication {
  final String name;
  final String description;
  final double dosageMg;
  final String unit;
  final List<String> interactions;

  Medication({
    required this.name,
    required this.description,
    required this.dosageMg,
    required this.unit,
    required this.interactions,
  });

  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      name: map['name'],
      description: map['description'],
      dosageMg: map['dosageMg'].toDouble(),
      unit: map['unit'],
      interactions: List<String>.from(map['interactions']),
    );
  }
}

class UserProfile {
  final double weightKg;
  final int age;
  final bool hasKidneyIssues;
  final bool hasLiverIssues;

  UserProfile({
    required this.weightKg,
    required this.age,
    required this.hasKidneyIssues,
    required this.hasLiverIssues,
  });
}

class DoseLog {
  final Medication medication;
  final DateTime timestamp;
  final double dosage;

  DoseLog({
    required this.medication,
    required this.timestamp,
    required this.dosage,
  });
}
