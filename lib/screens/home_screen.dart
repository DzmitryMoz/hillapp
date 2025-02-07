// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/health_data.dart';
import '../calendar/models/calendar_medication.dart';
import '../calendar/models/calendar_medication_intake.dart';
import '../calendar/service/calendar_database_service.dart';
import '../calendar/screens/calendar_screen.dart';
import 'blood_pressure_screen.dart';
import 'medicine_screen.dart';
import 'for_moms_screen.dart';
import 'profile_screen.dart';

// Цветовые константы
const Color kMintLight = Color(0xFF00E5D1);
const Color kMintDark = Color(0xFF00B4AB);
const Color kBackground = Color(0xFFE3FDFD);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key); // Параметр onToggleTheme удалён

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CalendarDatabaseService _calendarDbService = CalendarDatabaseService();

  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _calendarDbService.loadMedications();
    _pages = [
      const _HomePage(),
      const MedicineScreen(),
      const ForMomsScreen(),
      const ProfileScreen(),
    ];
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Главная';
      case 1:
        return 'Медицина';
      case 2:
        return 'Для мам';
      case 3:
        return 'Профиль';
      default:
        return 'HillApp';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Верхняя панель с градиентным фоном
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kMintLight, kMintDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                const SizedBox(width: 16),
                // Заголовок экрана
                Expanded(
                  child: Text(
                    _getTitle(_currentIndex),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Основное содержимое – переключение между вкладками
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      // Нижняя навигационная панель
      bottomNavigationBar: _buildBottomNavBar(context),
      backgroundColor: kBackground,
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: kMintDark,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            backgroundColor: kMintDark,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_hospital),
                label: 'Медицина',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.child_care),
                label: 'Для мам',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Профиль',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------- Содержимое главной вкладки ----------------------
class _HomePage extends StatefulWidget {
  const _HomePage({Key? key}) : super(key: key);

  @override
  State<_HomePage> createState() => __HomePageState();
}

class __HomePageState extends State<_HomePage> {
  final CalendarDatabaseService _calendarDbService = CalendarDatabaseService();

  DateTime _selectedDay = DateTime.now();
  Map<String, CalendarMedication> _medicationMap = {};
  List<CalendarMedicationIntake> _todayMedications = [];

  @override
  void initState() {
    super.initState();
    _loadMedications();
    _updateTodayMedications();
  }

  Future<void> _loadMedications() async {
    final meds = await _calendarDbService.getAllCalendarMedications();
    setState(() {
      _medicationMap = {for (var med in meds) med.id: med};
    });
  }

  Future<void> _updateTodayMedications() async {
    final meds = await _calendarDbService.getMedicationsForDay(_selectedDay);
    setState(() {
      _todayMedications = meds;
    });
  }

  void _goFullCalendar() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    ).then((_) {
      _updateTodayMedications();
      _loadMedications();
    });
  }

  void _goBloodPressure() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BloodPressureScreen()),
    );
  }

  void _goAnalysisDecryption() {
    Navigator.pushNamed(context, '/analysis_main');
  }

  void _goMedicationCalculator() {
    Navigator.pushNamed(context, '/medication_calculator');
  }

  // Мини-календарь в стиле карточки
  Widget _buildMiniCalendar() {
    final now = DateTime.now();
    final days = List.generate(
      7,
          (i) => DateTime(now.year, now.month, now.day + i),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: days.map((day) {
          final isToday = _sameDay(day, now);
          final isSelected = _sameDay(day, _selectedDay);

          Color bgColor = Colors.transparent;
          if (isToday) bgColor = kMintLight.withOpacity(0.2);
          if (isSelected) bgColor = kMintLight.withOpacity(0.5);

          return Flexible(
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedDay = day);
                _updateTodayMedications();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 40,
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
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
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

  @override
  Widget build(BuildContext context) {
    // Получение последних показателей из Provider
    final healthData = Provider.of<HealthData>(context);
    final latestMeasurement = healthData.latestMeasurement;

    return Container(
      color: kBackground,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Мини-календарь
          _buildMiniCalendar(),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          // Кнопка «Полноценный календарь»
          _buildGradientButton(
            icon: Icons.calendar_month,
            label: 'Календарь',
            onTap: _goFullCalendar,
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          // Приёмы препаратов на день
          if (_todayMedications.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Text('Нет приёма препаратов на этот день.'),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: kMintLight, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Препараты на выбранный день:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (var med in _todayMedications) _buildMedicationTile(med),
                ],
              ),
            ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          // Блок: Последний показатель АД и ЧСС (с цветовой подсветкой и увеличенным шрифтом)
          if (latestMeasurement != null) ...[
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Заголовок с иконкой
                    Row(
                      children: const [
                        Icon(Icons.favorite, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text(
                          'Последний показатель АД и ЧСС:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Дата: ${_formatDate(latestMeasurement.date)}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    // Выделяем АД
                    Builder(
                      builder: (context) {
                        final systolic = latestMeasurement.systolic;
                        final diastolic = latestMeasurement.diastolic;

                        // Пример логики
                        String shortStatus = '';
                        Color adColor = Colors.black;
                        if (systolic >= 140) {
                          shortStatus = ' (Повышенное)';
                          adColor = Colors.redAccent;
                        } else if (systolic < 100) {
                          shortStatus = ' (Низкое)';
                          adColor = Colors.blueAccent;
                        } else {
                          shortStatus = ' (Норма)';
                          adColor = Colors.green;
                        }

                        return Text(
                          'АД: $systolic/$diastolic мм рт. ст.$shortStatus',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: adColor,
                          ),
                        );
                      },
                    ),
                    // Выделяем ЧСС
                    Builder(
                      builder: (context) {
                        final hr = latestMeasurement.heartRate;
                        String hrStatus = '';
                        Color hrColor = Colors.black;

                        if (hr < 60) {
                          hrStatus = ' (Низкий)';
                          hrColor = Colors.blueAccent;
                        } else if (hr > 100) {
                          hrStatus = ' (Высокий)';
                          hrColor = Colors.redAccent;
                        } else {
                          hrStatus = ' (Норма)';
                          hrColor = Colors.green;
                        }

                        return Text(
                          'ЧСС: $hr уд/мин$hrStatus',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: hrColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Нет данных. Введите последние показатели.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          // Кнопки действий: Контроль АД, Расшифровка анализов, Калькулятор лекарств
          _buildGradientButton(
            icon: Icons.monitor_heart,
            label: 'Контроль АД',
            onTap: _goBloodPressure,
          ),
          const SizedBox(height: 12),
          _buildGradientButton(
            icon: Icons.description,
            label: 'Расшифровка анализов',
            onTap: _goAnalysisDecryption,
          ),
          const SizedBox(height: 12),
          _buildGradientButton(
            icon: Icons.calculate,
            label: 'Калькулятор лекарств',
            onTap: _goMedicationCalculator,
          ),
        ],
      ),
    );
  }

  // Элемент списка препаратов
  Widget _buildMedicationTile(CalendarMedicationIntake intake) {
    final med = _medicationMap[intake.medicationId];
    final name = med?.name ?? 'Неизвестный препарат';
    final dosage = med?.dosage ?? '-';
    final unit = med?.dosageUnit.displayName ?? '';
    final timeText = intake.time.format(context);
    final intakeTypeLabel = intake.intakeType.displayName;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: kMintDark,
          radius: 14,
          child: const Icon(Icons.medical_services, color: Colors.white, size: 18),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Дозировка: $dosage $unit\nВремя: $timeText, Приём: $intakeTypeLabel',
        ),
      ),
    );
  }

  // Универсальный стиль для кнопок
  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: kMintDark,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d.$m.$y';
  }
}
