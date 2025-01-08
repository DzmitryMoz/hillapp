// lib/screens/medicina_screen.dart

import 'package:flutter/material.dart';

class MedicinaScreen extends StatelessWidget {
  const MedicinaScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> info = const [
    {
      'title': 'Справочник лекарств',
      'desc': 'Описание популярных препаратов, инструкции.',
    },
    {
      'title': 'Первая помощь',
      'desc': 'Как действовать в экстренных ситуациях.',
    },
    {
      'title': 'Рекомендации по здоровью',
      'desc': 'Общие советы по здоровому образу жизни.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Медицина'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: info.length,
        itemBuilder: (context, i) {
          final item = info[i];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(item['title']!),
              subtitle: Text(item['desc']!),
            ),
          );
        },
      ),
    );
  }
}
