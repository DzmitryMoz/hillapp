// lib/analysis/screens/analysis_result_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert'; // Для jsonEncode
import '../analysis_colors.dart';
import '../analysis_service.dart';
import '../db/analysis_history_db.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String researchId;
  final AnalysisService analysisService;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final List<Map<String, dynamic>> results;

  const AnalysisResultScreen({
    Key? key,
    required this.researchId,
    required this.analysisService,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    required this.results,
  }) : super(key: key);

  Future<void> _saveToHistory(BuildContext context) async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'patientName': patientName,
      'patientAge': patientAge,
      'patientSex': patientSex,
      'researchId': researchId,
      // Сохраняем результаты в JSON
      'results': jsonEncode(results),
    };

    try {
      await AnalysisHistoryDB().insertRecord(record);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Анализ сохранён в историю')),
      );
    } catch (e) {
      // Если, например, таблица не найдена => покажем ошибку
      print('Ошибка при сохранении: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final research = analysisService.findResearchById(researchId);
    final title = research?['title'] ?? 'Результаты';

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: kMintDark,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Информация о пациенте
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
                Text('Имя: $patientName', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Возраст: $patientAge, Пол: $patientSex'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Выводим список результатов
          ...results.map((r) => _buildResultItem(r, research)).toList(),

          const SizedBox(height: 16),

          // Кнопки
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('На главную'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _saveToHistory(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMintDark,
                  ),
                  child: const Text('Сохранить'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildResultItem(Map<String,dynamic> res, Map<String,dynamic>? research) {
    final id = res['id'];
    final name = res['name'] ?? '';
    final status = res['status'] ?? '';
    final value = res['value'];

    // Если у вас есть find indicator
    final indicator = (research?['indicators'] as List?)?.firstWhere(
          (el) => el['id'] == id,
      orElse: () => null,
    );

    final bgColor = _getBgColorFromStatus(status);

    if (indicator == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$name: Неизвестный показатель'),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name: $value', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Статус: $status'),
          // ... Можно добавить причины/рекомендации
        ],
      ),
    );
  }

  Color _getBgColorFromStatus(String status) {
    if (status.contains('В норме')) {
      return Colors.green.shade50;
    } else if (status.contains('Выше') || status.contains('Ниже')) {
      return Colors.red.shade50;
    }
    return Colors.white;
  }
}
