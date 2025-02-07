import 'package:flutter/material.dart';
import '../../utils/app_colors.dart'; // Относительный путь к файлу с цветами

class MedicationCalculatorScreen extends StatelessWidget {
  const MedicationCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: AppColors.kMintDark,
      ),
      body: Center(
        child: Text(
          'Дима думает...',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.kMintDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
