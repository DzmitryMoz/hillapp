// lib/screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/pill.dart';
import '../utils/pill_types.dart';
import 'add_pill_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  final Map<DateTime, List<Pill>> _pillSchedule = {
    DateTime.utc(2023, 10, 25): [
      Pill(name: 'Парацетамол', time: '08:00'),
      Pill(name: 'Амоксициллин', time: '20:00'),
    ],
    DateTime.utc(2023, 10, 26): [
      Pill(name: 'Витамин D', time: '09:00'),
    ],
    // Добавьте другие даты и таблетки по необходимости
  };

  List<Pill> _getPillsForDay(DateTime day) {
    return _pillSchedule[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  void _addPill(DateTime date, Pill pill) {
    final day = DateTime.utc(date.year, date.month, date.day);
    if (_pillSchedule.containsKey(day)) {
      _pillSchedule[day]!.add(pill);
    } else {
      _pillSchedule[day] = [pill];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Главный экран'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Пример других элементов главного экрана
            // Например, приветственное сообщение
            const Text(
              'Добро пожаловать в приложение по приему таблеток!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2.0),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: TableCalendar<Pill>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: _getPillsForDay,
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  markersMaxCount: 1,
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
                calendarBuilders: CalendarBuilders(
                  todayBuilder: (context, date, focusedDay) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  selectedBuilder: (context, date, focusedDay) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${date.day}',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                  markerBuilder: (context, date, events) {
                    if (events.isNotEmpty) {
                      return Positioned(
                        bottom: 1,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final Pill? newPill = await showDialog<Pill>(
                  context: context,
                  builder: (context) => const AddPillDialog(),
                );

                if (newPill != null) {
                  _addPill(_selectedDay, newPill);
                }
              },
              child: const Text('Добавить таблетку'),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _getPillsForDay(_selectedDay).isEmpty
                  ? const Center(
                child: Text(
                  'В этот день приёма таблеток нет.',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'План приёма таблеток:',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _getPillsForDay(_selectedDay).length,
                      itemBuilder: (context, index) {
                        final pill = _getPillsForDay(_selectedDay)[index];
                        return ListTile(
                          leading: const Icon(Icons.medication),
                          title: Text(pill.name),
                          trailing: Text(pill.time),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Другие элементы главного экрана ниже календаря
            // Например, кнопки действий
          ],
        ),
      ),
    );
  }
}
