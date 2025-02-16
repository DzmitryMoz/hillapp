import 'package:flutter/material.dart';

class BabyCareScreen extends StatelessWidget {
  const BabyCareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уход за малышом (0-1 год и далее)'),
      ),
      body: Center(
        child: Text(
          'Содержимое экрана ухода за малышом',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
