// lib/calculator/educational_resources.dart

import 'package:flutter/material.dart';

class EducationalResources extends StatelessWidget {
  const EducationalResources({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Example educational resources
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: const [
        Text(
          'Образовательные ресурсы',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Информация о лекарствах:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
            'Здесь будет информация о различных лекарствах, их показаниях, противопоказаниях и побочных эффектах.'),
        SizedBox(height: 10),
        Text(
          'Советы по соблюдению режима приема:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
            'Полезные рекомендации для обеспечения правильного и своевременного приема лекарств.'),
      ],
    );
  }
}
