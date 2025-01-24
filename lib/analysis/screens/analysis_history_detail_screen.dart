// lib/analysis/screens/analysis_history_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert'; // для jsonDecode
import '../analysis_colors.dart';

class AnalysisHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const AnalysisHistoryDetailScreen({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = item['date'] ?? '';
    final pName = item['patientName'] ?? '';
    final pAge = item['patientAge']?.toString() ?? '';
    final pSex = item['patientSex'] ?? '';
    final researchId = item['researchId'] ?? '';
    final rawResults = item['results'] ?? '';

    // Парсим поле 'results', если оно JSON
    List<dynamic> parsedResults = [];
    try {
      parsedResults = jsonDecode(rawResults) as List<dynamic>;
    } catch (_) {
      // Если не JSON, parsedResults останется пустым
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Детали сохранённого анализа'),
        backgroundColor: kMintDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Краткая информация
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0,2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Дата: $date', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Пациент: $pName, $pAge лет, $pSex'),
                  const SizedBox(height: 4),
                  Text('Исследование: $researchId'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Блок результатов
            if (parsedResults.isEmpty)
            // Если мы не смогли распарсить JSON, покажем сырой текст
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0,2),
                    )
                  ],
                ),
                child: Text('Результаты: $rawResults'),
              )
            else
            // Перебираем каждый показатель
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: parsedResults.map((res) {
                  // res = { 'id': ..., 'name': ..., 'value': ..., 'status': ... }
                  return _buildResultRow(res);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(Map<String, dynamic> res) {
    final name = res['name'] ?? '';
    final value = res['value'];
    final status = (res['status'] ?? '') as String;

    // Определим цвет statis: зелёный = норма, красный = отклонение
    Color statusColor = Colors.black;
    if (status.contains('В норме')) {
      statusColor = Colors.green;
    } else if (status.contains('Выше') || status.contains('Ниже')) {
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0,2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name: $value'),
          const SizedBox(height: 4),
          Text(
            status,
            style: TextStyle(color: statusColor),
          ),
        ],
      ),
    );
  }
}
