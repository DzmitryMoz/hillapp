import 'package:flutter/material.dart';
import 'pregnancy_preparation_screen.dart';
import 'childbirth_preparation_screen.dart';
import 'childbirth_planning_screen.dart';

class GeneralPreparationScreen extends StatelessWidget {
  const GeneralPreparationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Предварительное планирование'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SectionButton(
            title: 'Подготовка к беременности',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PregnancyPreparationScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Подготовка к родам',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChildbirthPreparationScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Планирование родов',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChildbirthPlanningScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SectionButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const SectionButton({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        // Тень для кнопки
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        // Градиентный фон
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6DD5FA),
            Color(0xFF2980B9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
