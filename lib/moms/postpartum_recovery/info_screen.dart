import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class InfoScreen extends StatelessWidget {
  final String title;
  final String markdownContent;

  const InfoScreen({
    Key? key,
    required this.title,
    required this.markdownContent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Markdown(
        data: markdownContent,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
      ),
    );
  }
}
