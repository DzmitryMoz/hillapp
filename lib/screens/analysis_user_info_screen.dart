// lib/screens/analysis_user_info_screen.dart

import 'package:flutter/material.dart';
import '../models/research.dart';
import '../models/user_input.dart';
import 'analysis_indicators_screen.dart';

class AnalysisUserInfoScreen extends StatefulWidget {
  final Research research;

  const AnalysisUserInfoScreen({Key? key, required this.research})
      : super(key: key);

  @override
  State<AnalysisUserInfoScreen> createState() =>
      _AnalysisUserInfoScreenState();
}

class _AnalysisUserInfoScreenState extends State<AnalysisUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _userName = '';
  int _age = 0;
  double _weight = 0.0;

  void _navigateToIndicators() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final userInput = UserInput(
        userName: _userName,
        age: _age,
        weight: _weight,
        userResults: {},
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AnalysisIndicatorsScreen(
            research: widget.research,
            userInput: userInput,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Информация о пользователе'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Имя',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите имя';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _userName = value!.trim();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Возраст',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите возраст';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age <= 0) {
                      return 'Введите корректный возраст';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _age = int.parse(value!.trim());
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Вес (кг)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Введите вес';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Введите корректный вес';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _weight = double.parse(value!.trim());
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _navigateToIndicators,
                  child: const Text('Далее'),
                ),
              ],
            ),
          ),
        ));
  }
}
