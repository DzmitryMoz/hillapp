// lib/screens/analysis_decryption_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart'; // Используем пакет logger для логирования
import '../models/analysis.dart';
import '../models/analysis_result.dart';
import '../services/analysis_service.dart';
import '../services/history_service.dart';

class AnalysisDecryptionScreen extends StatefulWidget {
  const AnalysisDecryptionScreen({Key? key}) : super(key: key);

  @override
  State<AnalysisDecryptionScreen> createState() => _AnalysisDecryptionScreenState();
}

class _AnalysisDecryptionScreenState extends State<AnalysisDecryptionScreen> {
  final AnalysisService _analysisService = AnalysisService();
  final HistoryService _historyService = HistoryService();
  final Logger _logger = Logger(); // Инициализируем Logger

  bool _isLoading = true;
  List<Analysis> _analyses = [];
  Analysis? _selectedAnalysis;
  double? _userValue;
  String _interpretation = '';
  List<String> _recommendations = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _analysisService.loadAnalyses();
      await _historyService.init();
      setState(() {
        _analyses = _analysisService.analyses;
        _isLoading = false;
      });
      _logger.i('Анализы успешно загружены: ${_analyses.length}');
    } catch (e) {
      _logger.e('Ошибка при инициализации: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Ошибка при загрузке анализов.');
    }
  }

  void _interpretAnalysis() async {
    if (_selectedAnalysis == null || _userValue == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Интерпретация
      if (_userValue! < _selectedAnalysis!.normalMin) {
        _interpretation = 'Уровень ниже нормы';
      } else if (_userValue! > _selectedAnalysis!.normalMax) {
        _interpretation = 'Уровень выше нормы';
      } else {
        _interpretation = 'Уровень в норме';
      }

      // Сохранение результата
      final result = AnalysisResult(
        id: const Uuid().v4(),
        analysisId: _selectedAnalysis!.id,
        value: _userValue!,
        date: DateTime.now(),
      );

      await _historyService.addAnalysisResult(result);
      _logger.i('Результат анализа сохранен: ${result.toMap()}');

      // Генерация рекомендаций (пример)
      _recommendations = _generateRecommendations(_selectedAnalysis!, _userValue!);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _logger.e('Ошибка при интерпретации анализа: $e');
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Ошибка при интерпретации анализа.');
    }
  }

  List<String> _generateRecommendations(Analysis analysis, double value) {
    List<String> recommendations = [];

    if (value < analysis.normalMin) {
      recommendations.add('Рассмотрите возможность консультации с врачом.');
    } else if (value > analysis.normalMax) {
      recommendations.add('Рекомендуется повторить анализ через 1 неделю.');
    } else {
      recommendations.add('Ваш уровень находится в пределах нормы.');
    }

    return recommendations;
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
        title: const Text('Расшифровка Анализов'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Добавляем прокрутку
          child: Column(
            children: [
              DropdownButtonFormField<Analysis>(
                decoration: const InputDecoration(
                  labelText: 'Выберите анализ',
                  border: OutlineInputBorder(),
                ),
                value: _selectedAnalysis,
                items: _analyses.map((analysis) {
                  return DropdownMenuItem<Analysis>(
                    value: analysis,
                    child: Text(analysis.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAnalysis = value;
                    _userValue = null;
                    _interpretation = '';
                    _recommendations = [];
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Пожалуйста, выберите анализ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              if (_selectedAnalysis != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Введите ваше значение (${_selectedAnalysis!.unit})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Значение',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (value) {
                        setState(() {
                          _userValue = double.tryParse(value);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _userValue != null ? _interpretAnalysis : null,
                      child: const Text('Интерпретировать'),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (_interpretation.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Интерпретация:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      _interpretation,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              if (_recommendations.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рекомендации:',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    ..._recommendations.map((rec) => Text('- $rec')),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
