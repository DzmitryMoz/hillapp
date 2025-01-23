// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../../services/app_database.dart';

// Если хотите использовать единые константы цветов —
// можно вынести их в app_colors.dart, здесь укажем напрямую:
const Color kMintLight = Color(0xFF00E5D1);
const Color kMintDark  = Color(0xFF00B4AB);

class RegisterScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const RegisterScreen({
    Key? key,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController       = TextEditingController();
  final TextEditingController _emailController      = TextEditingController();
  final TextEditingController _passwordController   = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool _obscurePassword        = true;
  bool _obscureConfirmPassword = true;
  double _passwordStrength     = 0.0;

  late AnimationController _animationController;
  late Animation<double> _animation;

  String? errorText;

  @override
  void initState() {
    super.initState();

    // Анимация появления экрана
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Отслеживаем ввод пароля
    _passwordController.addListener(() {
      _checkPasswordStrength(_passwordController.text);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Простая логика для подсчёта силы пароля
  void _checkPasswordStrength(String password) {
    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
    });
  }

  Color get _passwordColor {
    if (_passwordStrength <= 0.25) {
      return Colors.red;
    } else if (_passwordStrength <= 0.5) {
      return Colors.orange;
    } else if (_passwordStrength <= 0.75) {
      return Colors.yellow;
    } else {
      return Colors.green;
    }
  }

  String get _passwordStrengthText {
    if (_passwordStrength <= 0.25) {
      return 'Слабый';
    } else if (_passwordStrength <= 0.5) {
      return 'Средний';
    } else if (_passwordStrength <= 0.75) {
      return 'Хороший';
    } else {
      return 'Отличный';
    }
  }

  /// Хэш пароля (sha256)
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Регистрация
  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        isLoading = true;
        errorText = null;
      });

      final name     = _nameController.text.trim();
      final email    = _emailController.text.trim();
      final password = _passwordController.text.trim();
      final hashedPassword = _hashPassword(password);

      try {
        final db = await AppDatabase.getInstance();

        await db.insert(
          'Users',
          {
            'name': name,
            'email': email,
            'password': hashedPassword,
          },
          conflictAlgorithm: ConflictAlgorithm.fail,
        );

        final ctx = _formKey.currentContext;
        if (ctx != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(content: Text('Регистрация прошла успешно!')),
          );
          Navigator.pushReplacementNamed(ctx, '/login');
        }
      } on DatabaseException catch (e) {
        if (e.isUniqueConstraintError()) {
          setState(() {
            errorText = 'Данный email уже используется';
          });
        } else {
          setState(() {
            errorText = 'Ошибка при регистрации: $e';
          });
        }
      } catch (e) {
        setState(() {
          errorText = 'Ошибка при регистрации: $e';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  /// Назад к экрану логина
  void _goBack() {
    final ctx = _formKey.currentContext;
    if (ctx != null) {
      Navigator.pop(ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Вместо обычного AppBar — градиентный фон на весь экран
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
            child: FadeTransition(
              opacity: _animation,
              child: ScaleTransition(
                scale: _animation,
                child: Container(
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
                          // Картинка (SVG)
                          SvgPicture.asset(
                            'assets/icons/register.svg',
                            height: 100,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 16),

                          // Заголовок
                          Text(
                            'Регистрация',
                            style: GoogleFonts.lato(
                              textStyle:
                              Theme.of(context).textTheme.headlineMedium,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Поле имени
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.person),
                              labelText: 'Имя',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Введите ваше имя';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

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
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Введите корректный email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Поле «Пароль»
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
                            onChanged: (val) => _checkPasswordStrength(val),
                          ),
                          const SizedBox(height: 8),

                          // Индикатор силы пароля
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: _passwordStrength,
                                  backgroundColor: Colors.grey[300],
                                  color: _passwordColor,
                                  minHeight: 5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _passwordStrengthText,
                                style: TextStyle(
                                  color: _passwordColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Подтверждение пароля
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock),
                              labelText: 'Подтверждение пароля',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Подтвердите пароль';
                              }
                              if (value != _passwordController.text) {
                                return 'Пароли не совпадают';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Ошибка (дубликат email, и пр.)
                          if (errorText != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              errorText!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ],

                          // Кнопка «Зарегистрироваться»
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _register,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: isLoading
                                  ? const SpinKitCircle(
                                color: Colors.white,
                                size: 24.0,
                              )
                                  : Text(
                                'Зарегистрироваться',
                                style: GoogleFonts.lato(
                                  textStyle: Theme.of(context)
                                      .textTheme
                                      .labelLarge,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Ссылка «Уже есть аккаунт? Войти»
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Уже есть аккаунт? '),
                              GestureDetector(
                                onTap: _goBack,
                                child: Text(
                                  'Войти',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
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
        ),
      ),
    );
  }
}
