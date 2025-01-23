// lib/screens/analysis_indicators_screen.dart

import 'package:flutter/material.dart';
import '../models/research.dart';
import '../models/user_input.dart';
import 'analysis_result_screen.dart';
import '../services/database_service.dart';
import '../models/indicator.dart';


class AnalysisIndicatorsScreen extends StatefulWidget {
  final Research research;
  final UserInput userInput;

  const AnalysisIndicatorsScreen({
    Key? key,
    required this.research,
    required this.userInput,
  }) : super(key: key);

  @override
  State<AnalysisIndicatorsScreen> createState() =>
      _AnalysisIndicatorsScreenState();
}

class _AnalysisIndicatorsScreenState extends State<AnalysisIndicatorsScreen> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _isNormal = {}; // Отслеживание статуса нормальности
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    for (var indicator in widget.research.indicators) {
      final controller = TextEditingController();
      controller.addListener(() {
        _validateIndicator(indicator, controller.text);
      });
      _controllers[indicator.id] = controller;
      _isNormal[indicator.id] = true; // Изначально считаем нормальным
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _validateIndicator(Indicator indicator, String input) {
    final value = double.tryParse(input);
    bool normal = false;
    if (value != null && !value.isNaN && !value.isInfinite) {
      normal = value >= indicator.normalMin && value <= indicator.normalMax;
    }
    setState(() {
      _isNormal[indicator.id] = normal;
    });
  }

  void _navigateToResult() async {
    print('Кнопка "Расшифровать" нажата'); // Отладочное сообщение
    final Map<String, double> results = {};
    bool hasError = false;

    for (var indicator in widget.research.indicators) {
      final controller = _controllers[indicator.id];
      if (controller != null) {
        final input = controller.text.trim();
        final value = double.tryParse(input);
        if (value == null || value.isNaN || value.isInfinite) {
          hasError = true;
          break;
        }
        results[indicator.id] = value;
      }
    }

    if (hasError) {
      print('Ошибка: Некорректные значения введены'); // Отладочное сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите корректные значения')),
      );
      return;
    }

    final updatedUserInput = UserInput(
      userName: widget.userInput.userName,
      age: widget.userInput.age,
      weight: widget.userInput.weight,
      userResults: results,
    );

    try {
      // Сохранение результата в базу данных
      await _databaseService.insertAnalysis(updatedUserInput, widget.research.id);
      print('Результаты успешно сохранены'); // Отладочное сообщение

      // Навигация к экрану результатов
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisResultScreen(
            research: widget.research,
            userInput: updatedUserInput,
          ),
        ),
      );
    } catch (e) {
      print('Ошибка при сохранении результатов: $e'); // Отладочное сообщение
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении результатов: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.research.title),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: widget.research.indicators.length,
                  itemBuilder: (context, index) {
                    final indicator = widget.research.indicators[index];
                    final normal = _isNormal[indicator.id] ?? true;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: normal ? Colors.green.shade50 : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                indicator.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                  'Норма: ${indicator.normalMin} - ${indicator.normalMax} ${indicator.unit}'),
                              const SizedBox(height: 6),
                              TextField(
                                controller: _controllers[indicator.id],
                                decoration: InputDecoration(
                                  labelText:
                                  'Введите значение (${indicator.unit})',
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                              ),
                            ]),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _navigateToResult,
                  icon: const Icon(Icons.check),
                  label: const Text('Расшифровать'),
                  style: ElevatedButton.styleFrom(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
