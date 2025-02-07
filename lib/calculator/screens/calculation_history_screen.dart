// lib/calculator/screens/calculation_history_screen.dart

import 'package:flutter/material.dart';

/// Экран «История расчётов» (минимальный пример).
/// Позже вы можете заполнить его реальными данными из калькулятора.
class CalculationHistoryScreen extends StatelessWidget {
  const CalculationHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История расчётов'),
      ),
      body: const Center(
        child: Text('Здесь будет история расчётов'),
      ),
    );
  }
}
