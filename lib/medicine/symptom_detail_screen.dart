import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class SymptomDetailScreen extends StatelessWidget {
  final String symptomName;
  final String symptomDetail;

  const SymptomDetailScreen({
    Key? key,
    required this.symptomName,
    required this.symptomDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(symptomName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        // Используем trim(), чтобы удалить лишние пробелы в начале и конце
        child: MarkdownBody(
          data: symptomDetail.trim(),
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            p: const TextStyle(fontSize: 16),
            strong: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
