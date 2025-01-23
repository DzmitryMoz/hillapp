// lib/calculator/widgets/result_card.dart

import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String medicationName;
  final double dosage;
  final String dosageUnit;
  final String administrationRoute;
  final String calculationType;
  final bool isValid;

  const ResultCard({
    Key? key,
    required this.medicationName,
    required this.dosage,
    required this.dosageUnit,
    required this.administrationRoute,
    required this.calculationType,
    required this.isValid,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isValid ? Colors.green.shade100 : Colors.red.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Название: $medicationName',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Дозировка: ${dosage.toStringAsFixed(2)} $dosageUnit'),
            const SizedBox(height: 8),
            Text('Путь введения: $administrationRoute'),
            const SizedBox(height: 8),
            Text('Метод расчета: $calculationType'),
            const SizedBox(height: 8),
            Text(
              isValid
                  ? 'Рекомендуемая доза: ${dosage.toStringAsFixed(2)} $dosageUnit'
                  : 'Дозировка превышает допустимую. Проверьте введенные данные.',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Пожалуйста, перепроверьте правильность введенных данных.',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
