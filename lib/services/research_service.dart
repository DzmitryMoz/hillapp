// lib/services/research_service.dart

import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/research.dart';
import '../models/indicator.dart';

class ResearchService {
  final List<Research> _researches = [];

  List<Research> get researches => _researches;

  Future<void> loadResearches() async {
    try {
      final String response =
      await rootBundle.loadString('assets/data/research_list.json');
      final List<dynamic> data = json.decode(response);

      _researches.clear();
      for (var item in data) {
        final List<dynamic> indList = item['indicators'];
        final indicators = indList.map((ind) {
          return Indicator.fromMap(ind);
        }).toList();

        _researches.add(
          Research(
            id: item['id'],
            title: item['title'],
            description: item['description'],
            indicators: indicators,
          ),
        );
      }
      print('Анализы успешно загружены: ${_researches.length}');
    } catch (e) {
      print('Ошибка при загрузке видов исследований: $e');
      throw Exception('Не удалось загрузить виды исследований');
    }
  }

  Research? getResearchById(String id) {
    try {
      return _researches.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}
