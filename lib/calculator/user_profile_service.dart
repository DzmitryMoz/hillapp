// lib/calculator/user_profile_service.dart

import 'calculator_model.dart';

class UserProfileService {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
  }
}
