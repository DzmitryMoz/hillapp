// lib/calculator/schedule_manager.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleManager extends StatefulWidget {
  const ScheduleManager({Key? key}) : super(key: key);

  @override
  State<ScheduleManager> createState() => _ScheduleManagerState();
}

class _ScheduleManagerState extends State<ScheduleManager> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, List<String>> _medicationSchedules = {};

  void _addMedicationSchedule(String medicationName) {
    if (_selectedDay != null) {
      setState(() {
        if (_medicationSchedules[_selectedDay!] != null) {
          _medicationSchedules[_selectedDay!]!.add(medicationName);
        } else {
          _medicationSchedules[_selectedDay!] = [medicationName];
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Расписание добавлено')),
      );
    }
  }

  void _showAddScheduleDialog() {
    String medicationName = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить расписание'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Название лекарства'),
            onChanged: (value) {
              medicationName = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (medicationName.isNotEmpty) {
                  _addMedicationSchedule(medicationName);
                }
                Navigator.of(context).pop();
              },
              child: const Text('Добавить'),
            ),
          ],
        );
      },
    );
  }

  List<String> _getMedicationsForDay(DateTime day) {
    return _medicationSchedules[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2100, 12, 31),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          eventLoader: _getMedicationsForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showAddScheduleDialog,
          child: const Text('Добавить расписание'),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _selectedDay == null
              ? const Center(child: Text('Выберите день для просмотра расписания.'))
              : _getMedicationsForDay(_selectedDay!).isEmpty
              ? const Center(child: Text('Нет расписаний на выбранный день.'))
              : ListView(
            children: _getMedicationsForDay(_selectedDay!).map((med) {
              return ListTile(
                title: Text(med),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
