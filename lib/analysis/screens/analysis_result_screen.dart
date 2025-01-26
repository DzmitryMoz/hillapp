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
  final String patientSex; // 'male' / 'female'
  final List<Map<String, dynamic>> results; // [{id, name, value, ...}, ...]

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
                Text('Имя: $patientName',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
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

  /// Строит виджет для одного показателя
  Widget _buildResultItem(Map<String, dynamic> res, Map<String, dynamic>? research) {
    final id = res['id'];
    final name = res['name'] ?? '';
    // В вашем коде 'status' может быть заранее сгенерирован,
    // но мы сейчас хотим вычислять его из JSON.
    // Если нужно использовать старое значение — оставьте 'final status = res['status']'.
    // Или вычислим заново в зависимости от нормы:

    final dynamic rawValue = res['value'];
    double? value;
    if (rawValue is num) {
      value = rawValue.toDouble();
    } else {
      // Если не число, выводим как строку
    }

    // Находим описание показателя в JSON (через research)
    final indicator = (research?['indicators'] as List?)?.firstWhere(
          (el) => el['id'] == id,
      orElse: () => null,
    );

    // Если не нашли — просто выводим
    if (indicator == null) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text('$name: $rawValue (Неизвестный показатель)'),
      );
    }

    final bgColor = Colors.white; // будет сменяться ниже при статусе?
    // Получаем нормальные границы
    final normalRange = indicator['normalRange'] as Map<String, dynamic>?;

    // Извлечём массив [min, max] в зависимости от пола, возраста
    List<double> range = _findRangeForPatient(normalRange, patientSex, patientAge);

    final double minVal = range[0];
    final double maxVal = range[1];

    // Определяем статус, причину и рекомендации
    String computedStatus = 'В норме';
    String cause = '';
    String recommendation = '';

    if (value != null) {
      if (value < minVal) {
        computedStatus = 'Ниже нормы';
        cause = indicator['causesLower'] ?? '';
        recommendation = indicator['recommendationLower'] ?? '';
      } else if (value > maxVal) {
        computedStatus = 'Выше нормы';
        cause = indicator['causesHigher'] ?? '';
        recommendation = indicator['recommendationHigher'] ?? '';
      }
      // Иначе value внутри [minVal, maxVal] => "В норме"
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBgColorFromStatus(computedStatus),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$name: ${value ?? rawValue}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Статус: $computedStatus'),
          // Показать нормальный диапазон
          Text('Норма: $minVal – $maxVal'),

          // Если есть причины/рекомендации
          if (cause.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Причины: $cause',
                style: const TextStyle(color: Colors.redAccent)),
          ],
          if (recommendation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Рекомендации: $recommendation',
                style: const TextStyle(color: Colors.blue)),
          ],
        ],
      ),
    );
  }

  /// Определяем цвет фона в зависимости от статуса
  Color _getBgColorFromStatus(String status) {
    if (status.contains('В норме')) {
      return Colors.green.shade50;
    } else if (status.contains('Выше') || status.contains('Ниже')) {
      return Colors.red.shade50;
    }
    return Colors.white;
  }

  /// Ищем нормальный диапазон с учётом пола и возраста (упрощённый вариант).
  /// Возвращаем [min, max].
  /// Если ничего не нашли — вернём [0, 999999].
  List<double> _findRangeForPatient(
      Map<String, dynamic>? normalRange,
      String sex,
      int age,
      ) {
    if (normalRange == null) {
      return [0, 999999];
    }

    // Например, в JSON:
    // "normalRange": {
    //   "male": { "adult": [4.0, 9.0] },
    //   "female": { "adult": [4.0, 9.0] }
    // }
    // Пытаемся взять normalRange[sex], затем "adult" или "any"
    if (normalRange.containsKey(sex)) {
      final sexMap = normalRange[sex];
      if (sexMap is Map<String, dynamic>) {
        // Пытаемся взять "adult"
        if (sexMap.containsKey('adult')) {
          final list = sexMap['adult'];
          return _parseRangeList(list);
        } else if (sexMap.containsKey('any')) {
          final list = sexMap['any'];
          return _parseRangeList(list);
        }
      }
    }

    // Если не нашли — пробуем "any" в корне
    if (normalRange.containsKey('any')) {
      final list = normalRange['any'];
      return _parseRangeList(list);
    }

    // Иначе [0..999999] как fallback
    return [0, 999999];
  }

  /// Преобразует список [минимум, максимум] из dynamic в List<double>
  List<double> _parseRangeList(dynamic list) {
    if (list is List && list.length == 2) {
      final double minVal = (list[0] as num).toDouble();
      final double maxVal = (list[1] as num).toDouble();
      return [minVal, maxVal];
    }
    return [0, 999999];
  }
}
