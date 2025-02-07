// lib/analysis/analysis_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';

class AnalysisService {
  List<dynamic>? _researches;

  /// Загружаем JSON-файл из папки assets/analysis/data
  Future<void> loadAnalysisData() async {
    final dataString =
    await rootBundle.loadString('lib/analysis/data/analysis_data.json');
    final jsonData = json.decode(dataString) as Map<String, dynamic>;
    _researches = jsonData['researches'] as List<dynamic>;

    print('AnalysisService: JSON loaded with ${_researches?.length ?? 0} researches.');
  }

  /// Возвращаем список всех исследований
  List<dynamic> getAllResearches() {
    return _researches ?? [];
  }

  /// Ищем нужное исследование (например, "cbc", "urinalysis") по id
  Map<String, dynamic>? findResearchById(String researchId) {
    if (_researches == null) {
      print('AnalysisService: _researches is null. JSON not loaded?');
      return null;
    }
    final found = _researches!.firstWhere(
          (r) => r['id'] == researchId,
      orElse: () => null,
    );
    if (found == null) {
      print('AnalysisService: Research with id="$researchId" not found.');
    }
    return found;
  }

  /// Возвращает диапазон [min, max] для заданного показателя, пола (sex) и возраста (age).
  /// Возможные ключи: "0-1", "1-6", "7-14", "14+", "adult", "any".
  List<double>? getReferenceRange(
      Map<String, dynamic> indicator,
      String sex,
      int age,
      ) {
    final normalRange = indicator['normalRange'] as Map<String, dynamic>?;

    print('--- getReferenceRange ---');
    print('Indicator: ${indicator['id']} | Sex: $sex | Age: $age');

    if (normalRange == null) {
      print('No "normalRange" found in indicator "${indicator['id']}".');
      return null;
    }

    // 1) Секция для данного пола, если нет — fallback 'any'
    var rangesBySex = normalRange[sex] as Map<String, dynamic>?;
    if (rangesBySex == null) {
      print('No data for sex="$sex". Trying fallback "any"...');
      rangesBySex = normalRange['any'] as Map<String, dynamic>?;
    }

    if (rangesBySex == null) {
      print('No data for sex="$sex" nor "any".');
      return null;
    }

    // 2) Выбор ключа возрастного диапазона
    String? key;
    if (age < 1 && rangesBySex.containsKey('0-1')) {
      key = '0-1';
    } else if (age < 6 && rangesBySex.containsKey('1-6')) {
      key = '1-6';
    } else if (age < 14 && rangesBySex.containsKey('7-14')) {
      key = '7-14';
    } else {
      // Старше 14
      if (rangesBySex.containsKey('adult')) {
        key = 'adult';
      } else if (rangesBySex.containsKey('14+')) {
        key = '14+';
      } else if (rangesBySex.containsKey('any')) {
        key = 'any';
      }
    }

    if (key == null) {
      print('No suitable age key found for age=$age in sexes keys. Available keys: ${rangesBySex.keys}.');
      return null;
    }

    if (!rangesBySex.containsKey(key)) {
      print('Key="$key" not found in rangesBySex. Available keys: ${rangesBySex.keys}.');
      return null;
    }

    final val = rangesBySex[key];
    print('Using key="$key" -> $val');

    final parsed = _parseRange(val);
    if (parsed == null) {
      print('Could not parse range from $val.');
    } else {
      print('Resulting range: $parsed');
    }
    return parsed;
  }

  /// Вспомогательный метод: парсим [минимум, максимум]
  List<double>? _parseRange(dynamic val) {
    if (val is List && val.length == 2) {
      final double minVal = (val[0] as num).toDouble();
      final double maxVal = (val[1] as num).toDouble();
      return [minVal, maxVal];
    }
    return null;
  }

  /// Проверяем значение value, возвращаем:
  /// 'Ниже нормы', 'Выше нормы', 'В норме', либо 'Нет данных'.
  String checkValue({
    required Map<String, dynamic> indicator,
    required double value,
    required String sex,
    required int age,
  }) {
    final range = getReferenceRange(indicator, sex, age);
    if (range == null) {
      return 'Нет данных нормы';
    }
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
  String getCausesText(Map<String, dynamic> indicator, bool higher) {
    return higher
        ? (indicator['causesHigher'] ?? 'Нет информации')
        : (indicator['causesLower'] ?? 'Нет информации');
  }

  /// Рекомендации
  String getRecommendationText(Map<String, dynamic> indicator, bool higher) {
    return higher
        ? (indicator['recommendationHigher'] ?? 'Нет рекомендаций')
        : (indicator['recommendationLower'] ?? 'Нет рекомендаций');
  }
}
