// lib/calculator/history_log.dart

import 'package:flutter/material.dart';
import 'calculator_model.dart';

class HistoryLog extends StatelessWidget {
  final List<DoseLog> doseLogs;

  const HistoryLog({Key? key, required this.doseLogs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (doseLogs.isEmpty) {
      return const Center(
        child: Text('История приема лекарств пуста.'),
      );
    }

    return ListView.builder(
      itemCount: doseLogs.length,
      itemBuilder: (context, index) {
        final log = doseLogs[index];
        return ListTile(
          title: Text(log.medication.name),
          subtitle: Text(
              'Дозировка: ${log.dosage} ${log.medication.unit}\nВремя: ${log.timestamp.toLocal()}'),
        );
      },
    );
  }
}
