// lib/screens/add_pill_screen.dart

import 'package:flutter/material.dart';

class AddPillScreen extends StatefulWidget {
  const AddPillScreen({Key? key}) : super(key: key);

  @override
  State<AddPillScreen> createState() => _AddPillScreenState();
}

class _AddPillScreenState extends State<AddPillScreen> {
  final Map<String, String> pillTypeMap = {
    'Анальгетики': 'Обезболивающие средства',
    'Антибиотики': 'Препараты для борьбы с инфекциями',
    'Витамины': 'Комплексы витаминов и минералов',
    // Добавьте другие типы по необходимости
  };

  String? selectedPillType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить таблетку'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Тип таблетки',
              ),
              items: pillTypeMap.keys.map((String key) {
                return DropdownMenuItem<String>(
                  value: key,
                  child: Text(key),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedPillType = newValue;
                });
              },
              validator: (value) => value == null ? 'Выберите тип таблетки' : null,
            ),
            // Добавьте другие поля формы здесь
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Логика сохранения таблетки
              },
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
