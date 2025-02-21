import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Анимация контроллера (длительностью 0.8 секунды)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Анимация масштаба и плавного появления
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Запуск анимации
    _controller.forward();

    // Таймер на 1 секунду для быстрой загрузки
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Размеры для гибкой настройки
    const double iconSize = 180.0; // Крупная иконка
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Тот же градиент, который вам понравился
          gradient: LinearGradient(
            colors: [
              Color(0xFF80DEEA), // Светло-бирюзовый
              Color(0xFF00796B), // Темно-бирюзовый
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Анимация масштабирования иконки
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Image.asset(
                    'assets/icons/viv.png',
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
                const SizedBox(height: 24),
                // Анимация плавного появления текста
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      // Название приложения
                      Text(
                        'Карманный доктор',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Дополнительный слоган/описание
                      const Text(
                        'Ваш надежный помощник в мире здоровья',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
