import 'package:flutter/material.dart';

class PostpartumRecoveryScreen extends StatelessWidget {
  const PostpartumRecoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Послеродовой период и восстановление'),
      ),
      body: Center(
        child: Text(
          'Содержимое экрана послеродового периода и восстановления',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
