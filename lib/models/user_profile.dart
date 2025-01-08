// lib/models/user_profile.dart

/// Пример упрощённой модели профиля пользователя.
class UserProfile {
  final String id;
  final int age;
  final double weightKg;
  final bool hasKidneyIssues;
  final bool hasLiverIssues;
  final List<String> medicalHistory;

  UserProfile({
    required this.id,
    required this.age,
    required this.weightKg,
    required this.hasKidneyIssues,
    required this.hasLiverIssues,
    required this.medicalHistory,
  });
}
