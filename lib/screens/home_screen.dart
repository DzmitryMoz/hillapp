// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/health_data.dart';
import '../calendar/models/calendar_medication.dart';
import '../calendar/models/calendar_medication_intake.dart';
import '../calendar/service/calendar_database_service.dart';
import '../calendar/screens/calendar_screen.dart';
import 'blood_pressure_screen.dart';
import '../medicine/medicine_screen.dart';
import '../moms/for_moms_screen.dart';
import 'profile_screen.dart';

/// Цветовые константы – базовый цвет #00B4AB и его светлый вариант.
const Color kMintLight = Color(0xFF00E5D1); // Светлый оттенок
const Color kMintDark = Color(0xFF00B4AB);  // Базовый цвет #00B4AB
const Color kBackground = Color(0xFFE3FDFD);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
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
      MedicineScreen(),
      ForMomsScreen(),
      ProfileScreen(),
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
        return 'Настройки';
      default:
        return 'Карманный доктор';
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
          gradient: const LinearGradient(
            colors: [kMintLight, kMintDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
                icon: Icon(Icons.settings),
                label: 'Настройки',
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

  void _goFullCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );
    _updateTodayMedications();
    _loadMedications();
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
          // 1. Мини-календарь
          _buildMiniCalendar(),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 16),

          // 2. Блок с препаратами на выбранный день
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

          // 3. Кнопка "Календарь"
          _buildGradientCardButton(
            title: 'Календарь',
            description: 'Организуйте приём лекарств и контролируйте расписание лечения.',
            iconData: Icons.calendar_month,
            gradientColors: [kMintLight, kMintDark],
            onTap: _goFullCalendar,
          ),
          const SizedBox(height: 16),

          // 4. Блок: Последний показатель АД и ЧСС
          if (latestMeasurement != null)
            _buildLastMeasurementCard(latestMeasurement)
          else
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

          // 5. Кнопка "Контроль АД"
          _buildGradientCardButton(
            title: 'Контроль АД',
            description: 'Измерения и анализ показателей давления.',
            iconData: Icons.monitor_heart,
            gradientColors: [kMintLight, kMintDark],
            onTap: _goBloodPressure,
          ),
          const SizedBox(height: 12),
          // 6. Кнопка "Расшифровка анализов"
          _buildGradientCardButton(
            title: 'Расшифровка анализов',
            description: 'Посмотрите результаты и их интерпретацию.',
            iconData: Icons.description,
            gradientColors: [kMintLight, kMintDark],
            onTap: _goAnalysisDecryption,
          ),
          const SizedBox(height: 12),
          // 7. Кнопка "Калькулятор лекарств"
          _buildGradientCardButton(
            title: 'Калькулятор ИМТ',
            description: 'Быстрый расчёт индекса массы тела для оценки состояния вашего здоровья.',
            iconData: Icons.calculate,
            gradientColors: [kMintLight, kMintDark],
            onTap: _goMedicationCalculator,
          ),
        ],
      ),
    );
  }

  /// Карточка с последним показателем АД/ЧСС с балльной классификацией для любых данных
  Widget _buildLastMeasurementCard(dynamic measurement) {
    final dateString = _formatDate(measurement.date);
    final systolic = measurement.systolic;
    final diastolic = measurement.diastolic;
    final heartRate = measurement.heartRate;

    // -------------------- Балльная классификация для систолического давления --------------------
    int sbpScore;
    if (systolic < 100) {
      sbpScore = 1; // Низкое
    } else if (systolic < 120) {
      sbpScore = 2; // Оптимальное
    } else if (systolic < 130) {
      sbpScore = 3; // Норма
    } else if (systolic < 140) {
      sbpScore = 4; // Высокое нормальное
    } else if (systolic < 160) {
      sbpScore = 5; // 1 степень (мягкая)
    } else if (systolic < 180) {
      sbpScore = 6; // 2 степень (умеренная)
    } else {
      sbpScore = 7; // 3 степень (тяжёлая)
    }

    // -------------------- Балльная классификация для диастолического давления --------------------
    int dbpScore;
    if (diastolic < 60) {
      dbpScore = 1; // Низкое
    } else if (diastolic < 80) {
      dbpScore = 2; // Оптимальное
    } else if (diastolic < 85) {
      dbpScore = 3; // Норма
    } else if (diastolic < 90) {
      dbpScore = 4; // Высокое нормальное
    } else if (diastolic < 100) {
      dbpScore = 5; // 1 степень (мягкая)
    } else if (diastolic < 110) {
      dbpScore = 6; // 2 степень (умеренная)
    } else {
      dbpScore = 7; // 3 степень (тяжёлая)
    }

    // Итоговая категория определяется как максимум из двух баллов
    final overallScore = sbpScore > dbpScore ? sbpScore : dbpScore;

    // Маппинг баллов на текст и цвет
    String adStatus;
    Color adColor;
    switch (overallScore) {
      case 1:
        adStatus = '(Низкое)';
        adColor = Colors.blueAccent;
        break;
      case 2:
        adStatus = '(Оптимальное)';
        adColor = Colors.green;
        break;
      case 3:
        adStatus = '(Нормальное)';
        adColor = Colors.lightGreen;
        break;
      case 4:
        adStatus = '(Высокое нормальное)';
        adColor = Colors.yellow;
        break;
      case 5:
        adStatus = '(АГ 1 степени)';
        adColor = Colors.orange;
        break;
      case 6:
        adStatus = '(АГ 2 степени)';
        adColor = Colors.deepOrange;
        break;
      case 7:
        adStatus = '(АГ 3 степени)';
        adColor = Colors.red;
        break;
      default:
        adStatus = '(Неопределено)';
        adColor = Colors.grey;
    }

    // -------------------- Классификация для ЧСС --------------------
    String hrStatus = ' (Нормальный)';
    Color hrColor = Colors.green;
    if (heartRate < 60) {
      hrStatus = ' (Брадикардия)';
      hrColor = Colors.blueAccent;
    } else if (heartRate > 100) {
      hrStatus = ' (Тахикардия)';
      hrColor = Colors.redAccent;
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Верхняя строка: иконка + "Последний показатель", дата справа
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent),
                const SizedBox(width: 8),
                const Text(
                  'Последний показатель',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Text(
                  dateString,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const Divider(thickness: 1, height: 24),
            // Две "плитки": левая - АД, правая - ЧСС
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Левая плитка (АД)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.monitor_heart, color: Colors.blueAccent),
                            SizedBox(width: 8),
                            Text(
                              'АД:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'сист: $systolic\nдиаст: $diastolic',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Показатель: $adStatus',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: adColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Правая плитка (ЧСС)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade50,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.favorite, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text(
                              'ЧСС:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$heartRate уд/мин',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Показатель:$hrStatus',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: hrColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Мини-календарь
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

  // Карточка-кнопка (универсальная)
  Widget _buildGradientCardButton({
    required String title,
    required String description,
    required IconData iconData,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
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
                // Иконка в круглом полупрозрачном фоне
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    iconData,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                // Текстовая информация
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
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

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d.$m.$y';
  }
}
