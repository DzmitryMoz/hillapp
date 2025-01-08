// lib/screens/search_screen.dart

import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Реализуйте содержимое экрана поиска
      appBar: AppBar(title: const Text('Поиск')),
      body: const Center(
        child: Text(
          'Экран поиска',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
