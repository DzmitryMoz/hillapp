// lib/screens/analysis_detail_screen.dart

import 'package:flutter/material.dart';
import '../models/analysis.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';
import '../services/analysis_service.dart';

class AnalysisDetailScreen extends StatefulWidget {
  final Analysis analysis;

  const AnalysisDetailScreen({Key? key, required this.analysis}) : super(key: key);

  @override
  State<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends State<AnalysisDetailScreen> {
  final HistoryService _historyService = HistoryService();
  final AnalysisService _analysisService = AnalysisService();

  bool _isLoading = true;
  List<AnalysisResult> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      await _historyService.init();
      await _analysisService.loadAnalyses();
      final results = await _historyService.getAllHistory();
      setState(() {
        _history = results.where((result) => result.analysisId == widget.analysis.id).toList();
        _isLoading = false;
      });
      print('История для анализа ${widget.analysis.name} загружена: ${_history.length} записей');
    } catch (e) {
      print('Ошибка при загрузке истории анализа: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Ошибка при загрузке истории анализа.');
    }
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
          title: Text(widget.analysis.name),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
            ? const Center(child: Text('Нет сохраненных результатов для этого анализа.'))
            : ListView.builder(
          itemCount: _history.length,
          itemBuilder: (context, index) {
            final result = _history[index];
            return ListTile(
              title: Text('${result.value} ${widget.analysis.unit}'),
              subtitle: Text('Дата: ${result.date.day}.${result.date.month}.${result.date.year}'),
            );
          },
        ));
  }
}
