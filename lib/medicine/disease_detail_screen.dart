// lib/medicine/disease_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class DiseaseDetailScreen extends StatelessWidget {
  final String diseaseName;
  final String diseaseCategory;
  final String diseaseDetail;

  const DiseaseDetailScreen({
    Key? key,
    required this.diseaseName,
    required this.diseaseCategory,
    required this.diseaseDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Определяем доступную ширину с учетом отступов (16 пикселей с каждой стороны)
    final double maxWidth = MediaQuery.of(context).size.width - 32;

    return Scaffold(
      appBar: AppBar(
        title: Text(diseaseName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Отображение категории болезни под названием
            Text(
              diseaseCategory,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            // Ограничиваем ширину Markdown контента
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: MarkdownBody(
                data: diseaseDetail.trim(),
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  h2: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  p: const TextStyle(fontSize: 16),
                  strong: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
