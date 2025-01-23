// lib/screens/for_moms_screen.dart

import 'package:flutter/material.dart';

class ForMomsScreen extends StatelessWidget {
  const ForMomsScreen({Key? key}) : super(key: key);

  final List<Map<String, String>> tips = const [
    {
      'title': 'Лог развития ребёнка',
      'desc': 'Основные этапы роста и развития малыша по месяцам.',
    },
    {
      'title': 'Вопрос врачу',
      'desc': 'Популярные вопросы и ответы педиатров.',
    },
    {
      'title': 'Советы по питанию',
      'desc': 'Рекомендации по питанию матери и ребёнка.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: tips.length,
      itemBuilder: (context, i) {
        final item = tips[i];
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
