import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class FirstAidDetailScreen extends StatelessWidget {
  final String title;
  final String detail;

  const FirstAidDetailScreen({
    Key? key,
    required this.title,
    required this.detail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: MarkdownBody(
          data: detail,
          selectable: true, // Позволяет выделять текст
          styleSheet: MarkdownStyleSheet(
            h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            p: const TextStyle(fontSize: 16),
            strong: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            blockquote: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
