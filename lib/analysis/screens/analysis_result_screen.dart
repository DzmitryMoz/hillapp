// lib/analysis/screens/analysis_result_screen.dart

import 'package:flutter/material.dart';
import '../analysis_service.dart';
import '../analysis_colors.dart';
// Если используете историю
import '../db/analysis_history_db.dart';

class AnalysisResultScreen extends StatelessWidget {
  final String researchId;
  final AnalysisService analysisService;
  final String patientName;
  final int patientAge;
  final String patientSex;
  final List<Map<String,dynamic>> results;

  const AnalysisResultScreen({
    Key? key,
    required this.researchId,
    required this.analysisService,
    required this.patientName,
    required this.patientAge,
    required this.patientSex,
    required this.results,
  }) : super(key: key);

  Future<void> _saveToHistory() async {
    final record = {
      'date': DateTime.now().toIso8601String(),
      'patientName': patientName,
      'patientSex': patientSex,
      'patientAge': patientAge,
      'researchId': researchId,
      'results': results.toString(),
    };
    await AnalysisHistoryDB().insertRecord(record);
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
          ...results.map((r) => _buildResultItem(r, research)).toList(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('На главную'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await _saveToHistory();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сохранено в историю')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kMintDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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

    final indicator = (research?['indicators'] as List?)?.firstWhere(
            (el) => el['id'] == id,
        orElse: () => null
    );

    // Определим фон
    final bgColor = _getBgColorFromStatus(status);

    if (indicator == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0,2),
            )
          ],
        ),
        child: Text('$name: Неизвестный показатель'),
      );
    }

    bool isHigher = status.contains('Выше');
    bool isLower = status.contains('Ниже');

    final reasons = (isHigher || isLower)
        ? analysisService.getCausesText(indicator, isHigher)
        : null;
    final recco = (isHigher || isLower)
        ? analysisService.getRecommendationText(indicator, isHigher)
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
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
          Text('$name: $value', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Статус: $status'),
          if (reasons != null && recco != null) ...[
            const SizedBox(height: 8),
            Text('Возможные причины:\n$reasons'),
            const SizedBox(height: 4),
            Text('Рекомендации:\n$recco'),
          ]
        ],
      ),
    );
  }

  /// Если "В норме" → зелёный фон, если отклонение → красный, иначе белый
  Color _getBgColorFromStatus(String status) {
    if (status.contains('В норме')) {
      return Colors.green.shade50;
    } else if (status.contains('Выше') || status.contains('Ниже')) {
      return Colors.red.shade50;
    }
    return Colors.white;
  }
}
