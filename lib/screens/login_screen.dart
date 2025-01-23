// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';

import '../../services/app_database.dart';

// Если хотите переиспользовать цвета, можно вынести в app_colors.dart
const Color kMintLight = Color(0xFF00E5D1);
const Color kMintDark  = Color(0xFF00B4AB);
const Color kBackground= Color(0xFFE3FDFD);

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginScreen({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword = true;
  String? errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Вычисляем хэш пароля
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Метод входа
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        errorText = null;
      });

      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final hashedPassword = _hashPassword(password);

      try {
        final db = await AppDatabase.getInstance();
        final users = await db.query(
          'Users',
          where: 'email = ? AND password = ?',
          whereArgs: [email, hashedPassword],
        );

        if (users.isNotEmpty) {
          final ctx = _formKey.currentContext;
          if (ctx != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Вход успешен!')),
            );
            Navigator.pushReplacementNamed(ctx, '/home');
          }
        } else {
          setState(() {
            errorText = 'Неверный email или пароль';
          });
        }
      } catch (e) {
        setState(() {
          errorText = 'Ошибка при входе: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Переход к регистрации
  void _goToRegister() {
    final ctx = _formKey.currentContext;
    if (ctx != null) {
      Navigator.pushNamed(ctx, '/register');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Вместо обычного белого фона — светлый мятный
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kMintDark, kMintLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              // «Карточка» с белым фоном, закруглёнными углами, тенью
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Иконка (SVG) сверху
                      SvgPicture.asset(
                        'assets/icons/register.svg',
                        height: 100,
                        // можно оставить Theme.of(context).primaryColor
                        color: kMintDark,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Вход',
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Поле email
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.email),
                          labelText: 'Электронная почта',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите вашу электронную почту';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Введите корректный email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Поле пароль
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock),
                          labelText: 'Пароль',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите пароль';
                          }
                          if (value.length < 6) {
                            return 'Минимум 6 символов';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Ошибка, если есть
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],

                      // Кнопка «Войти»
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            // Градиент на кнопке, если хочется, придется городить ShaderMask
                            // Упростим: сделаем цвет фона = kMintDark
                            backgroundColor: kMintDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isLoading
                              ? const SpinKitCircle(
                            color: Colors.white,
                            size: 24.0,
                          )
                              : Text(
                            'Войти',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Ссылка на регистрацию
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Нет аккаунта? ',
                              style: TextStyle(color: Colors.black87)),
                          GestureDetector(
                            onTap: _goToRegister,
                            child: Text(
                              'Зарегистрироваться',
                              style: TextStyle(
                                color: kMintDark,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
