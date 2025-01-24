// lib/analysis/analysis_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';

class AnalysisService {
  List<dynamic>? _researches;

  /// ПУТЬ: меняйте, если файл в другом месте
  Future<void> loadAnalysisData() async {
    final dataString = await rootBundle.loadString('lib/analysis/data/analysis_data.json');
    final jsonData = json.decode(dataString) as Map<String, dynamic>;
    _researches = jsonData['researches'] as List<dynamic>;
  }

  List<dynamic> getAllResearches() {
    return _researches ?? [];
  }

  Map<String, dynamic>? findResearchById(String researchId) {
    if (_researches == null) return null;
    return _researches!.firstWhere(
            (r) => r['id'] == researchId,
        orElse: () => null
    );
  }

  /// Для конкретного показателя берём [min, max]
  List<double>? getReferenceRange(Map<String, dynamic> indicator, String sex, int age) {
    final normalRange = indicator['normalRange'] as Map<String, dynamic>?;
    if (normalRange == null) return null;
    final rangesBySex = normalRange[sex] as Map<String, dynamic>?;
    if (rangesBySex == null) return null;

    // Пример ключей: any, 0-1, 1-5, 6-12, 13-18, adult ...
    String key;
    if (rangesBySex.containsKey('any')) {
      key = 'any';
    } else if (age < 1 && rangesBySex.containsKey('0-1')) {
      key = '0-1';
    } else if (age < 5 && rangesBySex.containsKey('1-5')) {
      key = '1-5';
    } else if (age < 12 && rangesBySex.containsKey('6-12')) {
      key = '6-12';
    } else if (age < 18 && rangesBySex.containsKey('13-18')) {
      key = '13-18';
    } else {
      key = 'adult';
    }

    final val = rangesBySex[key];
    if (val == null) return null;
    return [(val[0] as num).toDouble(), (val[1] as num).toDouble()];
  }

  /// Возвращаем строку: 'В норме', 'Выше нормы', 'Ниже нормы'
  String checkValue({
    required Map<String, dynamic> indicator,
    required double value,
    required String sex,
    required int age,
  }) {
    final range = getReferenceRange(indicator, sex, age);
    if (range == null) return 'Нет данных нормы';
    final minVal = range[0];
    final maxVal = range[1];
    if (value < minVal) {
      return 'Ниже нормы ($minVal - $maxVal)';
    } else if (value > maxVal) {
      return 'Выше нормы ($minVal - $maxVal)';
    } else {
      return 'В норме ($minVal - $maxVal)';
    }
  }

  /// Причины отклонений
  String getCausesText(Map<String,dynamic> indicator, bool higher) {
    return higher
        ? (indicator['causesHigher'] ?? 'Нет информации')
        : (indicator['causesLower'] ?? 'Нет информации');
  }

  /// Рекомендации
  String getRecommendationText(Map<String,dynamic> indicator, bool higher) {
    return higher
        ? (indicator['recommendationHigher'] ?? 'Нет рекомендаций')
        : (indicator['recommendationLower'] ?? 'Нет рекомендаций');
  }
}
