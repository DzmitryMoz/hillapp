import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Таймер на 2 секунды, после которого переходим на главный экран.
    Timer(const Duration(seconds: 1), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mainSize = 64.0;
    const double heartSize = mainSize * 2; // 128 пикселей
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          color: AppColors.kWhite, // Белый фон
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Текст по центру
              Text(
                'MediScope',
                style: TextStyle(
                  fontSize: mainSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kMintDark,
                ),
              ),
              const SizedBox(height: 50),
              // Иконка сердца, размер увеличен в 2 раза
              Icon(
                Icons.favorite,
                size: heartSize,
                color: AppColors.kRedAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
