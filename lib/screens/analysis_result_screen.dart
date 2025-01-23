// lib/screens/analysis_result_screen.dart

import 'package:flutter/material.dart';
import '../models/research.dart';
import '../models/user_input.dart';
import '../services/recommendation_service.dart';

class AnalysisResultScreen extends StatelessWidget {
  final Research research;
  final UserInput userInput;

  AnalysisResultScreen({
    Key? key,
    required this.research,
    required this.userInput,
  }) : super(key: key);

  final RecommendationService _recService = RecommendationService();

  List<Widget> _buildResultCards(BuildContext context) {
    List<Widget> resultWidgets = [];

    for (var indicator in research.indicators) {
      final userValue = userInput.userResults[indicator.id]!;
      final isNormal =
          userValue >= indicator.normalMin && userValue <= indicator.normalMax;
      final color = isNormal ? Colors.green.shade100 : Colors.red.shade100;
      final recommendation = isNormal
          ? 'Показатель в норме.'
          : _recService.getRecommendation(indicator.id);

      resultWidgets.add(Card(
        color: color,
        margin: const EdgeInsets.symmetric(vertical: 8),
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
                Text('Ваш результат: $userValue ${indicator.unit}'),
                const SizedBox(height: 6),
                Text(
                  isNormal ? 'Всё хорошо.' : 'Отклонение от нормы!',
                  style: TextStyle(
                      color: isNormal ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation,
                  style: const TextStyle(color: Colors.black54),
                ),
              ]),
        ),
      ));
    }

    return resultWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Результаты анализов'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(
                color: Colors.blue.shade100,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Пользователь: ${userInput.userName}\nВозраст: ${userInput.age}\nВес: ${userInput.weight} кг',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              ..._buildResultCards(context),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(
                          context, ModalRoute.withName('/analysis_main'));
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('К списку анализов'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    },
                    icon: const Icon(Icons.home),
                    label: const Text('На главный экран'),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
