import 'package:flutter/material.dart';

class PsychologicalSupportScreen extends StatelessWidget {
  const PsychologicalSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Психологическая поддержка'),
      ),
      body: Center(
        child: Text(
          'Содержимое экрана психологической поддержки',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
