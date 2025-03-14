// lib/analysis/screens/analysis_result_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert'; // Для jsonEncode
import '../analysis_colors.dart';
import '../analysis_service.dart';
import '../db/analysis_history_db.dart';

class AnalysisResultScreen extends StatefulWidget {
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

  @override
  State<AnalysisResultScreen> createState() => _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends State<AnalysisResultScreen> {
  bool _isSaved = false; // Флаг, чтобы сохранить анализ только один раз

  /// Перевод пола на русский язык
  String _translateSex(String sex) {
    final lower = sex.toLowerCase();
    if (lower == 'male') return 'Мужской';
    if (lower == 'female') return 'Женский';
    return sex; // fallback, если вдруг другое значение
  }

  Future<void> _saveToHistory(BuildContext context) async {
    // Если уже сохранено — не сохраняем повторно
    if (_isSaved) return;

    setState(() {
      _isSaved = true;
    });

    final record = {
      'date': DateTime.now().toIso8601String(),
      'patientName': widget.patientName,
      'patientAge': widget.patientAge,
      'patientSex': widget.patientSex, // 'male'/'female'
      'researchId': widget.researchId,
      // Сохраняем результаты в JSON
      'results': jsonEncode(widget.results),
    };

    try {
      await AnalysisHistoryDB().insertRecord(record);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Анализ сохранён в историю')),
      );
    } catch (e) {
      // Если, например, таблица не найдена => покажем ошибку
      // Снова разрешаем сохранять
      setState(() {
        _isSaved = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final research = widget.analysisService.findResearchById(widget.researchId);
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
          // --- Информация о пациенте ---
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Имя: ${widget.patientName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Возраст: ${widget.patientAge}, Пол: ${_translateSex(widget.patientSex)}',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),

          // --- Список результатов ---
          ...widget.results.map((r) => _buildResultItem(r, research)).toList(),

          const SizedBox(height: 16),

          // --- Кнопки ---
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
                  child: Text(_isSaved ? 'Уже сохранено' : 'Сохранить'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// Строит виджет для одного показателя (качественный или количественный)
  Widget _buildResultItem(
      Map<String, dynamic> res,
      Map<String, dynamic>? research,
      ) {
    final id = res['id'];
    final name = res['name'] ?? '';
    final dynamic rawValue = res['value'];
    double? value;
    if (rawValue is num) {
      value = rawValue.toDouble();
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

    // Проверяем, есть ли у индикатора поле "options" (качественный показатель)
    final bool hasOptions = indicator.containsKey('options');

    // Начальные значения
    String computedStatus = 'В норме';
    String cause = '';
    String recommendation = '';
    double minVal = 0.0;
    double maxVal = 0.0;

    if (hasOptions) {
      // --- ЛОГИКА ДЛЯ КАЧЕСТВЕННЫХ ПОКАЗАТЕЛЕЙ (например, цвет, прозрачность) ---
      final selectedOption = rawValue.toString();

      // Для упрощения: если пользователь выбрал "Жёлтый" или "Прозрачная" —
      // считаем, что всё нормально. Если выбрал "Тёмно-жёлтый", "Оранжевый",
      // "Красный/Розовый" или "Мутная" — "Выше нормы". И т.д.
      // В реальном приложении логику можно расширить.

      // Пример для "color" (цвет мочи):
      if (selectedOption == 'Жёлтый' || selectedOption == 'Светло-жёлтый') {
        computedStatus = 'В норме';
        // cause / recommendation остаются пустыми
      } else if (selectedOption == 'Тёмно-жёлтый' ||
          selectedOption == 'Оранжевый' ||
          selectedOption == 'Красный/Розовый') {
        computedStatus = 'Выше нормы';
        cause = indicator['causesHigher'] ?? '';
        recommendation = indicator['recommendationHigher'] ?? '';
      } else {
        // Возможно, вариант "Слишком светлый" или нечто иное
        computedStatus = 'Ниже нормы';
        cause = indicator['causesLower'] ?? '';
        recommendation = indicator['recommendationLower'] ?? '';
      }

      // Пример для "clarity" (прозрачность):
      // if (selectedOption == 'Прозрачная' || selectedOption == 'Слегка мутная') {
      //   computedStatus = 'В норме';
      // } else if (selectedOption == 'Мутная') {
      //   computedStatus = 'Выше нормы';
      //   cause = indicator['causesHigher'] ?? '';
      //   recommendation = indicator['recommendationHigher'] ?? '';
      // } ...

    } else {
      // --- ЛОГИКА ДЛЯ КОЛИЧЕСТВЕННЫХ ПОКАЗАТЕЛЕЙ (pH, белок, глюкоза и т.д.) ---

      // Получаем нормальные границы
      final normalRange = indicator['normalRange'] as Map<String, dynamic>?;
      final range = _findRangeForPatient(
        normalRange,
        widget.patientSex,
        widget.patientAge,
      );
      minVal = range[0];
      maxVal = range[1];

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
      }
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
            '$name: $rawValue',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text('Статус: $computedStatus'),

          // Показываем нормальный диапазон ТОЛЬКО для количественных показателей
          if (!hasOptions)
            Text('Норма: $minVal – $maxVal'),

          if (cause.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Причины: $cause',
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ],
          if (recommendation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Рекомендации: $recommendation',
              style: TextStyle(color: Colors.teal.shade600),
            ),
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

    if (normalRange.containsKey(sex)) {
      final sexMap = normalRange[sex];
      if (sexMap is Map<String, dynamic>) {
        if (sexMap.containsKey('adult')) {
          return _parseRangeList(sexMap['adult']);
        } else if (sexMap.containsKey('any')) {
          return _parseRangeList(sexMap['any']);
        }
      }
    }

    if (normalRange.containsKey('any')) {
      return _parseRangeList(normalRange['any']);
    }

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
