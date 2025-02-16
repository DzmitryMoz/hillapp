import 'package:flutter/material.dart';

class PrePregnancyScreen extends StatelessWidget {
  const PrePregnancyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Подготовка к беременности и родам'),
      ),
      body: Center(
        child: Text(
          'Содержимое экрана подготовки к беременности и родам',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
