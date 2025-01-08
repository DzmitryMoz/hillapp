// lib/services/user_profile_service.dart

import '../models/user_profile.dart';

/// Сервис для работы с профилем пользователя.
class UserProfileService {
  UserProfile? userProfile;

  Future<void> init() async {
    // Заглушка для примера
    userProfile = UserProfile(
      id: 'user123',
      age: 30,
      weightKg: 70,
      hasKidneyIssues: false,
      hasLiverIssues: false,
      medicalHistory: [],
    );
  }
}
