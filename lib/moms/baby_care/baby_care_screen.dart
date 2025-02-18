import 'package:flutter/material.dart';
import 'baby_care_hygiene_screen.dart';
import 'baby_care_sleep_screen.dart';
import 'baby_care_walks_screen.dart';
import 'baby_care_development_screen.dart';
import 'baby_care_medical_screen.dart';
import 'baby_care_safety_screen.dart';
import 'baby_care_environment_screen.dart';

class BabyCareScreen extends StatelessWidget {
  const BabyCareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уход за малышом'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SectionButton(
            title: 'Гигиенический уход',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyCareHygieneScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Сон',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyCareSleepScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Прогулки и закаливание',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyCareWalksScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Развитие и игры',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyCareDevelopmentScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Медицинское наблюдение',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyCareMedicalScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Безопасность',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyCareSafetyScreen(),
                ),
              );
            },
          ),
          SectionButton(
            title: 'Гигиена окружающей среды',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BabyCareEnvironmentScreen(),
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
        // Пример градиентного фона (вы можете менять его по своему усмотрению)
        gradient: const LinearGradient(
          colors: [
            Color(0xFFC8E6C9), Color(0xFF388E3C)
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
                  color: Colors.white, // Белый цвет текста
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
