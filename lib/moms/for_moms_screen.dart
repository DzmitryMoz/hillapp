import 'package:flutter/material.dart';

// Пример импортов экранов для мам
import '../moms/pre_pregnancy/pre_pregnancy_screen.dart';
import '../moms/postpartum_recovery/postpartum_recovery_screen.dart';
import '../moms/baby_care/baby_care_screen.dart';
import '../moms/feeding_screen/baby_care_feeding_screen.dart';
import '../moms/growth_tracking/growth_tracking_screen.dart';

class ForMomsScreen extends StatelessWidget {
  ForMomsScreen({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> items = [
    {
      'title': 'Подготовка к беременности и родам',
      'desc': 'Полезные советы для планирования и подготовки к материнству.',
      'icon': Icons.pregnant_woman,
      'gradientColors': [Color(0xFFB3E5FC), Color(0xFF0288D1)],
      'screen': const PrePregnancyScreen(),
    },
    {
      'title': 'Послеродовой период и восстановление',
      'desc': 'Поддержка и рекомендации по восстановлению после родов.',
      'icon': Icons.healing,
      'gradientColors': [Color(0xFF9B111E), Color(0xFFE0115F)],
      'screen': const PostpartumRecoveryScreen(),
    },
    {
      'title': 'Уход за малышом (0-1 год и далее)',
      'desc': 'Информация по уходу, развитию и воспитанию ребенка.',
      'icon': Icons.child_friendly,
      'gradientColors': [Color(0xFFC8E6C9), Color(0xFF388E3C)],
      'screen': const BabyCareScreen(),
    },
    {
      'title': 'Кормление и детское питание',
      'desc': 'Рекомендации по грудному вскармливанию и введению прикорма.',
      'icon': Icons.restaurant,
      'gradientColors': [Color(0xFFFFCCBC), Color(0xFFD84315)],
      'screen': const FeedingScreen(),
    },
    {
      'title': 'Рост и развитие ребенка',
      'desc': 'Отслеживайте показатели роста и веса ребенка.',
      'icon': Icons.show_chart,
      'gradientColors': [Color(0xFFFFF176), Color(0xFFFDD835)],
      'screen': const GrowthTrackingScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar можно убрать, если нужен "чистый" вид

      backgroundColor: Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _MomsSectionButton(
            title: item['title'] as String,
            description: item['desc'] as String,
            iconData: item['icon'] as IconData,
            gradientColors: item['gradientColors'] as List<Color>,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => item['screen'] as Widget,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Карточка-раздел для поддержки мам с градиентом
class _MomsSectionButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MomsSectionButton({
    Key? key,
    required this.title,
    required this.description,
    required this.iconData,
    required this.gradientColors,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.5),
            offset: const Offset(0, 6),
            blurRadius: 6,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    iconData,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
