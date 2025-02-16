import 'package:flutter/material.dart';

class FeedingScreen extends StatelessWidget {
  const FeedingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Кормление и детское питание'),
      ),
      body: Center(
        child: Text(
          'Содержимое экрана кормления и детского питания',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
