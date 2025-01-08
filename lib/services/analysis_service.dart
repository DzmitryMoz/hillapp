// lib/services/analysis_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/analysis.dart';

class AnalysisService {
  List<Analysis> analyses = [];

  Future<void> loadAnalyses() async {
    try {
      final String response = await rootBundle.loadString('assets/data/analyses.json');
      final data = json.decode(response) as List<dynamic>;

      analyses = data.map((item) => Analysis.fromMap(item)).toList();
      print('Анализы успешно загружены: ${analyses.length}');
    } catch (e) {
      print('Ошибка при загрузке анализов: $e');
      throw Exception('Не удалось загрузить анализы');
    }
  }

  Analysis? getAnalysisById(String id) {
    try {
      return analyses.firstWhere((analysis) => analysis.id == id);
    } catch (e) {
      print('Анализ с ID $id не найден: $e');
      return null;
    }
  }
}
