// lib/widgets/mini_calendar.dart
import 'package:flutter/material.dart';

class MiniCalendar extends StatelessWidget {
  final VoidCallback onDayTap;
  const MiniCalendar({Key? key, required this.onDayTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(
      7,
          (index) => DateTime(now.year, now.month, now.day + index),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: days.map((day) {
        bool hasPills = day.day % 2 == 0; // заглушка для демо
        return GestureDetector(
          onTap: onDayTap,
          child: Column(
            children: [
              Text(_shortWeekday(day.weekday)),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: hasPills ? Colors.green : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.all(12),
                child: Text('${day.day}'),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _shortWeekday(int weekday) {
    switch (weekday) {
      case 1:
        return 'Пн';
      case 2:
        return 'Вт';
      case 3:
        return 'Ср';
      case 4:
        return 'Чт';
      case 5:
        return 'Пт';
      case 6:
        return 'Сб';
      case 7:
        return 'Вс';
      default:
        return '?';
    }
  }
}
