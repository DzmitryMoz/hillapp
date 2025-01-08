// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'calendar_screen.dart';
import 'blood_pressure_screen.dart';
import 'analysis_decryption_screen.dart';
import 'package:hillapp/calculator/calculator_screen.dart';
import 'analysis_history_screen.dart';
import 'support_screen.dart';
import 'feedback_screen.dart';
import 'view_feedback_screen.dart';
import 'analysis_list_screen.dart';
import '../models/medication.dart';
import '../models/medication_data.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomeScreen({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();

  final List<Map<String, dynamic>> bpMeasurements = [
    {
      'date': DateTime.utc(2023, 10, 28),
      'systolic': 125,
      'diastolic': 80,
      'pulse': 70,
    },
    {
      'date': DateTime.utc(2023, 10, 29),
      'systolic': 130,
      'diastolic': 85,
      'pulse': 75,
    },
  ];

  @override
  void initState() {
    super.initState();
    // При необходимости инициализируйте сервисы
  }

  List<Medication> _getPills(DateTime day) {
    return MedicationData().getMedications(day);
  }

  Map<String, dynamic>? get lastBP =>
      bpMeasurements.isEmpty ? null : bpMeasurements.last;

  void _goFullCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );
  }

  void _goBloodPressure() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BloodPressureScreen()),
    );
  }

  void _goAnalysis() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisDecryptionScreen()),
    );
  }

  void _goCalc() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalculatorScreen()),
    );
  }

  void _goSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SupportScreen()),
    );
  }

  void _goAnalysisHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AnalysisHistoryScreen()),
    );
  }

  void _goFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
    );
  }

  void _goViewFeedback() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ViewFeedbackScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pillsToday = _getPills(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Главная'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'HillApp',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('История Анализов'),
              onTap: () {
                Navigator.pop(context);
                _goAnalysisHistory();
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Поддержка'),
              onTap: () {
                Navigator.pop(context);
                _goSupport();
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback),
              title: const Text('Оставить Отзыв'),
              onTap: () {
                Navigator.pop(context);
                _goFeedback();
              },
            ),
            ListTile(
              leading: const Icon(Icons.rate_review),
              title: const Text('Просмотр Отзывов'),
              onTap: () {
                Navigator.pop(context);
                _goViewFeedback();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Выйти'),
              onTap: () {
                Navigator.pop(context);
                // Реализуйте логику выхода из приложения
              },
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMiniCalendar(),
          const SizedBox(height: 10),
          if (pillsToday.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.blueAccent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Препараты на выбранный день:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (var med in pillsToday)
                    Text('${med.name} (${med.dosage}) - ${med.time.format(context)}'),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white70,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Нет приёма препаратов на этот день.'),
            ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _goFullCalendar,
            icon: const Icon(Icons.calendar_month),
            label: const Text('Полноценный календарь'),
          ),
          const SizedBox(height: 20),
          if (lastBP != null) ...[
            Text(
              'Последний показатель АД: ${lastBP!["systolic"]}/${lastBP!["diastolic"]}  Пульс: ${lastBP!["pulse"]}',
              style:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
          ],
          ElevatedButton.icon(
            onPressed: _goBloodPressure,
            icon: const Icon(Icons.monitor_heart),
            label: const Text('Контроль АД'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _goAnalysis,
            icon: const Icon(Icons.description),
            label: const Text('Расшифровка анализов'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _goCalc,
            icon: const Icon(Icons.calculate),
            label: const Text('Калькулятор лекарств'),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCalendar() {
    final now = DateTime.now();
    final days = List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));

    return GestureDetector(
      onTap: _goFullCalendar,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white70,
          border: Border.all(color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: days.map((day) {
            final isToday = _sameDay(day, DateTime.now());
            final isSelected = _sameDay(day, _selectedDay);
            final hasPills = _getPills(day).isNotEmpty;

            Color bgColor = Colors.grey.shade200;
            if (isToday) bgColor = Colors.orange.shade300;
            if (hasPills) bgColor = Colors.green.shade300;
            if (isSelected) bgColor = Colors.blue.shade300;

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = day;
                });
              },
              child: Container(
                width: 48,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _weekdayLabel(day.weekday),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('${day.day}', style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekdayLabel(int w) {
    switch (w) {
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
        return '';
    }
  }
}
