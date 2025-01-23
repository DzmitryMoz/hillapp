// lib/calculator/screens/calculation_history_screen.dart

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/calculation_history.dart';

class CalculationHistoryScreen extends StatefulWidget {
  const CalculationHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CalculationHistoryScreen> createState() => _CalculationHistoryScreenState();
}

class _CalculationHistoryScreenState extends State<CalculationHistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<CalculationHistory> _histories = [];

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    final list = await _databaseService.getAllHistories();
    setState(() {
      _histories = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История расчётов'),
      ),
      body: _histories.isEmpty
          ? const Center(child: Text('История пуста.'))
          : ListView.builder(
        itemCount: _histories.length,
        itemBuilder: (context, index) {
          final hist = _histories[index];
          return ListTile(
            title: Text(hist.medicationName),
            subtitle: Text(
              'Доза: ${hist.calculatedDose}, Дата: ${hist.date.toIso8601String()}',
            ),
          );
        },
      ),
    );
  }
}
