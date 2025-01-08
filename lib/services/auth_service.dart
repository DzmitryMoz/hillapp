// lib/services/auth_service.dart

import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthService {
  final Box<UserModel> _userBox;

  AuthService(this._userBox);

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final existingUser = _userBox.values.firstWhere(
          (user) => user.email == email,
      orElse: () => UserModel(name: '', email: '', password: ''),
    );

    if (existingUser.email.isNotEmpty) {
      return false;
    }

    final newUser = UserModel(
      name: name,
      email: email,
      password: password,
    );

    await _userBox.add(newUser);
    return true;
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    final user = _userBox.values.firstWhere(
          (user) => user.email == email && user.password == password,
      orElse: () => UserModel(name: '', email: '', password: ''),
    );

    return user.email.isNotEmpty;
  }

  UserModel? getCurrentUser() {
    if (_userBox.isNotEmpty) {
      return _userBox.values.first;
    }
    return null;
  }
}
