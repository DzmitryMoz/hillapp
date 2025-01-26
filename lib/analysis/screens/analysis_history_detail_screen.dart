// lib/analysis/screens/analysis_history_detail_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert'; // для jsonDecode
import '../analysis_colors.dart';
import '../db/analysis_history_db.dart';
import 'package:flutter/foundation.dart';

class AnalysisHistoryDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;

  const AnalysisHistoryDetailScreen({Key? key, required this.item}) : super(key: key);

  Future<void> _deleteAnalysis(BuildContext context) async {
    final id = item['id'];
    if (id is! int) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: некорректный ID')),
      );
      return;
    }
    try {
      final db = AnalysisHistoryDB();
      await db.deleteRecord(id);
      Navigator.pop(context); // Закрываем экран
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Анализ удалён')),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка при удалении: $e');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении: $e')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить анализ'),
        content: const Text('Вы уверены, что хотите удалить этот анализ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteAnalysis(context);
            },
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final date = item['date'] ?? '';
    final pName = item['patientName'] ?? '';
    final pAge = item['patientAge']?.toString() ?? '';
    final pSex = item['patientSex'] ?? '';
    final rId = item['researchId'] ?? '';
    final rawResults = item['results'] ?? '';

    // Попробуем распарсить results
    List<dynamic> parsedResults = [];
    try {
      parsedResults = jsonDecode(rawResults) as List<dynamic>;
    } catch (e) {
      if (kDebugMode) {
        print('Ошибка парсинга results: $e');
      }
    }

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Детали анализа'),
        backgroundColor: kMintDark,
        actions: [
          IconButton(
            onPressed: () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Дата: $date', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Пациент: $pName, $pAge лет, $pSex'),
                  const SizedBox(height: 4),
                  Text('Исследование: $rId'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (parsedResults.isEmpty)
              Text('Сырые результаты:\n$rawResults')
            else
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: parsedResults.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 8),
                itemBuilder: (ctx, i) {
                  final r = parsedResults[i] as Map<String, dynamic>;
                  return _buildResultCard(r);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Map<String,dynamic> res) {
    final name = res['name'] ?? '';
    final value = res['value'];
    final status = res['status'] ?? '';

    return Card(
      child: ListTile(
        title: Text('$name: $value', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Статус: $status'),
      ),
    );
  }
}
