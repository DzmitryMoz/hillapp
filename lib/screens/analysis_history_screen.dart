// lib/screens/analysis_history_screen.dart

import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import '../models/analysis.dart';
import '../services/history_service.dart';
import '../services/analysis_service.dart';
import 'analysis_detail_screen.dart';
import 'analysis_list_screen.dart';
import 'package:logger/logger.dart'; // Добавляем импорт для логирования

class AnalysisHistoryScreen extends StatefulWidget {
  const AnalysisHistoryScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisHistoryScreen> createState() => _AnalysisHistoryScreenState();
}

class _AnalysisHistoryScreenState extends State<AnalysisHistoryScreen> {
  final HistoryService _historyService = HistoryService();
  final AnalysisService _analysisService = AnalysisService();
  final Logger _logger = Logger(); // Инициализируем Logger
  bool _isLoading = true;
  List<AnalysisResult> _history = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _historyService.init();
      await _analysisService.loadAnalyses();
      final results = await _historyService.getAllHistory();
      setState(() {
        // Фильтруем результаты, чтобы включить только те, которые соответствуют существующим анализам
        _history = results.where((result) => _analysisService.getAnalysisById(result.analysisId) != null).toList();
        _isLoading = false;
      });
      _logger.i('История анализов загружена: ${_history.length} записей');
    } catch (e) {
      _logger.e('Ошибка при загрузке истории анализов: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Ошибка при загрузке истории анализов.');
    }
  }

  Analysis? _getAnalysisById(String id) {
    return _analysisService.getAnalysisById(id);
  }

  void _goAnalysisList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisListScreen()),
    ).then((_) {
      _loadData();
    });
  }

  void _goAnalysisDetail(Analysis analysis) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisDetailScreen(analysis: analysis),
      ),
    ).then((_) {
      _loadData();
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
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
          ? const Center(child: Text('Нет сохраненных результатов.'))
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
          final analysis = _getAnalysisById(item.analysisId);
          final name = analysis?.name ?? 'Не найден';
          final unit = analysis?.unit ?? '';
          return ListTile(
            title: Text(name),
            subtitle: Text(
              'Значение: ${item.value} $unit\nДата: ${item.date.day}.${item.date.month}.${item.date.year}',
            ),
            onTap: () {
              if (analysis != null) {
                _goAnalysisDetail(analysis);
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goAnalysisList,
        child: const Icon(Icons.add),
        tooltip: 'Добавить Анализ',
      ),
    );
  }
}
