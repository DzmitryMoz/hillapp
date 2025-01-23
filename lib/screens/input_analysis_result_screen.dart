// lib/screens/input_analysis_result_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/analysis.dart';
import '../models/analysis_result.dart';
import '../services/history_service.dart';
import '../services/user_profile_service.dart';

class InputAnalysisResultScreen extends StatefulWidget {
  final Analysis analysis;

  const InputAnalysisResultScreen({Key? key, required this.analysis}) : super(key: key);

  @override
  _InputAnalysisResultScreenState createState() => _InputAnalysisResultScreenState();
}

class _InputAnalysisResultScreenState extends State<InputAnalysisResultScreen> {
  final HistoryService _historyService = HistoryService();
  final UserProfileService _userProfileService = UserProfileService();

  final TextEditingController _valueController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _historyService.init();
    _userProfileService.init();
  }

  void _saveResult() async {
    double? value = double.tryParse(_valueController.text.trim());
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите корректное значение')),
      );
      return;
    }

    final result = AnalysisResult(
      id: const Uuid().v4(),
      analysisId: widget.analysis.id,
      value: value,
      date: _selectedDate,
    );

    await _historyService.addAnalysisResult(result);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Результат сохранен в истории')),
    );

    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ввести Результат: ${widget.analysis.name}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: 'Значение (${widget.analysis.unit})',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    'Дата: ${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: const Text('Выбрать Дату'),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _saveResult,
                child: const Text('Сохранить Результат'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ));
  }
}
