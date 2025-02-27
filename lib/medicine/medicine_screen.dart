// lib/screens/medicine_screen.dart
import 'package:flutter/material.dart';
import '../medicine/first_aid_screen.dart';
import '../medicine/disease_list_screen.dart';
import '../medicine/symptoms_list_screen.dart';

class MedicineScreen extends StatelessWidget {
  MedicineScreen({Key? key}) : super(key: key);

  // Список с информацией для каждой кнопки.
  final List<Map<String, dynamic>> items = [
    {
      'title': 'Первая медицинская помощь',
      'desc': 'Как действовать в экстренных ситуациях.',
      'icon': Icons.medical_services,
      'gradientColors': [Color(0xFFFF8A80), Color(0xFFD32F2F)],
      'screen': FirstAidScreen(),
    },
    {
      'title': 'Справочник болезней',
      'desc': 'Описание различных болезней и рекомендации.',
      'icon': Icons.library_books,
      'gradientColors': [Color(0xFF81D4FA), Color(0xFF1976D2)],
      'screen': DiseaseListScreen(),
    },
    {
      'title': 'Справочник симптомов',
      'desc': 'Определите симптомы и узнайте, что с вами происходит.',
      'icon': Icons.search,
      'gradientColors': [Color(0xFFA5D6A7), Color(0xFF388E3C)],
      'screen': SymptomsListScreen(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return _MedicineButton(
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

/// Виджет-кнопка с красивым оформлением для разделов медицины.
class _MedicineButton extends StatelessWidget {
  final String title;
  final String description;
  final IconData iconData;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _MedicineButton({
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
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withOpacity(0.6),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Иконка в круглом полупрозрачном фоне
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
                // Текстовая информация: заголовок и описание
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
