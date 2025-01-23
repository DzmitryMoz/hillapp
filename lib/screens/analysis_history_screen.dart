// lib/screens/analysis_history_screen.dart

import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../models/user_input.dart';
import '../services/research_service.dart';
import 'analysis_result_screen.dart';
import 'dart:convert'; // Необходим для использования json.decode

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final ResearchService _researchService = ResearchService();
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      await _researchService.loadResearches(); // Загрузка исследований
      final history = await _databaseService.getAllAnalyses();
      setState(() {
        _history = history;
        _isLoading = false;
      });
      print('История анализов загружена: ${_history.length} записей');
    } catch (e) {
      // Обработка ошибок
      setState(() {
        _isLoading = false;
      });
      print('Ошибка при загрузке истории анализов: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при загрузке истории анализов: $e')),
      );
    }
  }

  void _viewResult(Map<String, dynamic> entry) {
    final userInput = UserInput(
      userName: entry['userName'],
      age: entry['age'],
      weight: entry['weight'],
      userResults:
      Map<String, double>.from(json.decode(entry['results'])),
    );
    final research = _researchService.getResearchById(entry['researchId']); // Исправлено 'researchId'

    if (research != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            research: research,
            userInput: userInput,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось найти исследование.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('История Анализов'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
            ? const Center(child: Text('История анализов пуста.'))
            : ListView.builder(
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final entry = _history[index];
            final date = DateTime.parse(entry['date']);
            final formattedDate =
                "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";

            final research = _researchService.getResearchById(entry['researchId']); // Определение исследования

            return ListTile(
              title: Text(research?.title ?? 'Неизвестное исследование'),
              subtitle: Text(
                  'Пользователь: ${entry['userName']}\nДата: $formattedDate'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => _viewResult(entry),
            );
          },
        ));
  }
}
