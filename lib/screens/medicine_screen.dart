// lib/screens/medicine_screen.dart

import 'package:flutter/material.dart';

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> items = const [
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
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        return Card(
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
          child: ListTile(
            title: Text(
              item['title'] ?? '',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(item['desc'] ?? ''),
          ),
        );
      },
    );
  }
}
