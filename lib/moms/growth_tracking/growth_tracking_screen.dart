import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // для CupertinoDatePicker
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Тип метрики: рост или вес
enum MetricType { height, weight }

/// Модель данных для пользовательских замеров
class UserMeasurement {
  final DateTime date;
  final double value;
  final MetricType type;

  UserMeasurement({
    required this.date,
    required this.value,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'value': value,
    'type': type.index,
  };

  factory UserMeasurement.fromJson(Map<String, dynamic> json) {
    return UserMeasurement(
      date: DateTime.parse(json['date']),
      value: json['value'],
      type: MetricType.values[json['type']],
    );
  }
}

/// Пример укороченных данных ВОЗ
class WhoDataPoint {
  final double month; // возраст в месяцах
  final double p50;   // 50-й перцентиль

  WhoDataPoint(this.month, this.p50);
}

/// Данные ВОЗ для роста (см)
final List<WhoDataPoint> whoHeightBoys = [
  WhoDataPoint(1, 54.7),
  WhoDataPoint(2, 58.4),
  WhoDataPoint(3, 61.4),
  WhoDataPoint(4, 63.9),
  WhoDataPoint(5, 65.9),
  WhoDataPoint(6, 67.6),
  WhoDataPoint(12, 75.7),
  WhoDataPoint(24, 87.8),
  WhoDataPoint(36, 97.0),
];

/// Данные ВОЗ для веса (кг)
final List<WhoDataPoint> whoWeightBoys = [
  WhoDataPoint(1, 4.2),
  WhoDataPoint(2, 5.3),
  WhoDataPoint(3, 6.1),
  WhoDataPoint(4, 6.7),
  WhoDataPoint(5, 7.2),
  WhoDataPoint(6, 7.6),
  WhoDataPoint(12, 9.6),
  WhoDataPoint(24, 12.2),
  WhoDataPoint(36, 14.3),
];

void main() {
  runApp(const MyApp());
}

/// Корневой виджет с глобальной темой
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // Глобальная тема: основной цвет – Color(0xFF00B4AB), фон – белый
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Рост / Вес ребёнка',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00B4AB),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.robotoTextTheme(Theme.of(context).textTheme),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00B4AB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      home: const GrowthTrackingScreen(),
    );
  }
}

class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({Key? key}) : super(key: key);

  @override
  State<GrowthTrackingScreen> createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen> {
  DateTime? childBirthDate;
  MetricType selectedMetric = MetricType.height;
  final List<UserMeasurement> userMeasurements = [];
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Загружаем данные, а затем, если дата рождения не установлена, показываем диалог
    _loadData().then((_) {
      if (childBirthDate == null) {
        _showBirthDateDialog();
      }
    });
  }

  /// Сохранение данных (дата рождения и замеры) в shared_preferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (childBirthDate != null) {
      await prefs.setString('birth_date', childBirthDate!.toIso8601String());
    }
    final measurementsJson = jsonEncode(
      userMeasurements.map((m) => m.toJson()).toList(),
    );
    await prefs.setString('measurements', measurementsJson);
  }

  /// Загрузка данных из shared_preferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final birthDateStr = prefs.getString('birth_date');
    if (birthDateStr != null) {
      childBirthDate = DateTime.parse(birthDateStr);
    }
    final measurementsStr = prefs.getString('measurements');
    if (measurementsStr != null) {
      final List<dynamic> measurementsJson = jsonDecode(measurementsStr);
      userMeasurements.clear();
      userMeasurements.addAll(
        measurementsJson.map((json) => UserMeasurement.fromJson(json)).toList(),
      );
    }
    setState(() {}); // Обновляем экран после загрузки данных
  }

  /// Диалог выбора даты рождения
  void _showBirthDateDialog() {
    final now = DateTime.now();
    final initial = childBirthDate ?? DateTime(now.year - 1, now.month, now.day);
    _showCenteredDatePicker(
      title: 'Укажите дату рождения ребёнка',
      initialDate: initial,
      minDate: DateTime(1900),
      maxDate: now,
      onDateSaved: (picked) {
        setState(() {
          childBirthDate = picked;
        });
        _saveData(); // Сохраняем дату рождения
      },
    );
  }

  /// Диалог добавления замера (рост/вес)
  void _showAddMeasurementDialog() {
    _valueController.clear();
    DateTime? measurementDate;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Text(
              selectedMetric == MetricType.height
                  ? 'Добавить показатель роста'
                  : 'Добавить показатель веса',
              style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.roboto(),
                  decoration: InputDecoration(
                    labelText: selectedMetric == MetricType.height ? 'Рост (см)' : 'Вес (кг)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('Дата замера: ', style: GoogleFonts.roboto()),
                    Text(
                      measurementDate == null
                          ? 'не выбрана'
                          : DateFormat('dd.MM.yyyy').format(measurementDate!),
                      style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4AB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    final now = DateTime.now();
                    final init = measurementDate ?? now;
                    final minD = childBirthDate ?? DateTime(1900);
                    _showCenteredDatePicker(
                      title: 'Выберите дату замера',
                      initialDate: init,
                      minDate: minD,
                      maxDate: now,
                      onDateSaved: (picked) {
                        setStateDialog(() {
                          measurementDate = picked;
                        });
                      },
                    );
                  },
                  child: Text('Выбрать дату', style: GoogleFonts.roboto(color: Colors.white)),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Отмена', style: GoogleFonts.roboto(color: Colors.black54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4AB),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  final val = double.tryParse(_valueController.text);
                  if (val == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Неверный формат числа')),
                    );
                    return;
                  }
                  if (measurementDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Дата не выбрана')),
                    );
                    return;
                  }
                  if (childBirthDate != null && measurementDate!.isBefore(childBirthDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Дата не может быть раньше рождения')),
                    );
                    return;
                  }
                  if (measurementDate!.isAfter(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Дата не может быть в будущем')),
                    );
                    return;
                  }
                  final newMeasurement = UserMeasurement(
                    date: measurementDate!,
                    value: val,
                    type: selectedMetric,
                  );
                  setState(() {
                    userMeasurements.add(newMeasurement);
                  });
                  _saveData(); // Сохраняем данные после добавления замера
                  Navigator.pop(ctx);
                },
                child: Text('Сохранить', style: GoogleFonts.roboto(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  /// Универсальный диалог с CupertinoDatePicker (без излишеств)
  void _showCenteredDatePicker({
    required String title,
    required DateTime initialDate,
    required DateTime minDate,
    required DateTime maxDate,
    required ValueChanged<DateTime> onDateSaved,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        DateTime tempDate = initialDate;
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    title,
                    style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Localizations.override(
                    context: context,
                    locale: const Locale('ru', 'RU'),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: initialDate,
                      minimumDate: minDate,
                      maximumDate: maxDate,
                      onDateTimeChanged: (picked) {
                        tempDate = picked;
                      },
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text('Отмена', style: GoogleFonts.roboto(color: Colors.black54)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00B4AB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        onDateSaved(tempDate);
                        Navigator.pop(ctx);
                      },
                      child: Text('Сохранить', style: GoogleFonts.roboto(color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Список данных ВОЗ (зависит от выбранной метрики)
  List<WhoDataPoint> get whoData {
    return selectedMetric == MetricType.height ? whoHeightBoys : whoWeightBoys;
  }

  /// Точки для графика по данным ВОЗ (50-й перцентиль)
  List<FlSpot> get whoSpots {
    return whoData.map((dp) => FlSpot(dp.month, dp.p50)).toList();
  }

  /// Точки для графика по пользовательским замерам
  List<FlSpot> get userSpots {
    if (childBirthDate == null) return [];
    final baseDate = childBirthDate!;
    final filtered = userMeasurements.where((m) => m.type == selectedMetric).toList();
    return filtered.map((m) {
      final diffDays = m.date.difference(baseDate).inDays;
      final months = diffDays / 30.0;
      return FlSpot(months, m.value);
    }).toList();
  }

  /// Подписи для оси X (возраст в месяцах)
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value >= 0 && value <= 36 && value % 6 == 0) {
      return Text(value.toStringAsFixed(0), style: GoogleFonts.roboto(fontSize: 10));
    }
    return const SizedBox();
  }

  /// Подписи для оси Y (в зависимости от метрики)
  Widget _buildLeftTitle(double value, TitleMeta meta) {
    if (selectedMetric == MetricType.height) {
      if (value % 10 == 0 && value >= 0 && value <= 120) {
        return Text(value.toStringAsFixed(0), style: GoogleFonts.roboto(fontSize: 10));
      }
    } else {
      if (value % 2 == 0 && value >= 0 && value <= 20) {
        return Text(value.toStringAsFixed(0), style: GoogleFonts.roboto(fontSize: 10));
      }
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    final maxY = selectedMetric == MetricType.height ? 120.0 : 20.0;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B4AB),
        title: Text('Рост / Вес ребёнка', style: GoogleFonts.roboto(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildBirthDateCard(),
                    const SizedBox(height: 16),
                    if (childBirthDate != null) _buildChartCard(maxY),
                    const SizedBox(height: 16),
                    if (childBirthDate != null) _buildMetricPicker(),
                    const SizedBox(height: 16),
                    if (childBirthDate != null && userMeasurements.isNotEmpty)
                      _buildMeasurementsTable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: childBirthDate != null
          ? FloatingActionButton.extended(
        backgroundColor: const Color(0xFF00B4AB),
        onPressed: _showAddMeasurementDialog,
        icon: const Icon(Icons.add),
        label: Text('Добавить показатель', style: GoogleFonts.roboto()),
      )
          : null,
    );
  }

  /// Карточка для выбора и отображения даты рождения
  Widget _buildBirthDateCard() {
    if (childBirthDate == null) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.cake_outlined, color: Color(0xFF00B4AB)),
          title: Text('Укажите дату рождения', style: GoogleFonts.roboto()),
          subtitle: Text('Нажмите, чтобы выбрать', style: GoogleFonts.roboto(fontSize: 12)),
          onTap: _showBirthDateDialog,
        ),
      );
    } else {
      final dateStr = DateFormat('dd.MM.yyyy').format(childBirthDate!);
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Icon(Icons.cake, color: Color(0xFF00B4AB)),
          title: Text('Дата рождения: $dateStr', style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
          subtitle: Text('Нажмите, чтобы изменить', style: GoogleFonts.roboto(fontSize: 12)),
          onTap: _showBirthDateDialog,
        ),
      );
    }
  }

  /// Карточка-график с минималистичными элементами (fl_chart)
  Widget _buildChartCard(double maxY) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 36,
            minY: 0,
            maxY: maxY,
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (List<LineBarSpot> touchedSpots) {
                  return touchedSpots.map((barSpot) {
                    final month = barSpot.x;
                    final value = barSpot.y;
                    return LineTooltipItem(
                      'Месяц: ${month.toStringAsFixed(1)}\nЗнач: ${value.toStringAsFixed(1)}',
                      GoogleFonts.roboto(color: Colors.black),
                    );
                  }).toList();
                },
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text(
                  selectedMetric == MetricType.height ? 'Рост (см)' : 'Вес (кг)',
                  style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                axisNameSize: 20,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: _buildLeftTitle,
                ),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  'Возраст (мес)',
                  style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                axisNameSize: 20,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  getTitlesWidget: _buildBottomTitle,
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            gridData: FlGridData(show: true),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              // Линия ВОЗ
              LineChartBarData(
                spots: whoSpots,
                isCurved: true,
                color: Colors.grey,
                barWidth: 2,
              ),
              // Линия пользовательских замеров
              LineChartBarData(
                spots: userSpots,
                isCurved: false,
                color: const Color(0xFF00B4AB),
                barWidth: 2,
                dotData: const FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Виджет для выбора метрики (рост/вес)
  Widget _buildMetricPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Метрика:', style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87)),
        const SizedBox(width: 16),
        DropdownButton<MetricType>(
          value: selectedMetric,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00B4AB)),
          items: const [
            DropdownMenuItem(value: MetricType.height, child: Text('Рост')),
            DropdownMenuItem(value: MetricType.weight, child: Text('Вес')),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                selectedMetric = val;
              });
            }
          },
        ),
      ],
    );
  }

  /// Таблица с введёнными данными
  Widget _buildMeasurementsTable() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Введённые данные:', style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DataTable(
              columnSpacing: 12,
              headingRowColor: MaterialStateProperty.all(const Color(0xFF00B4AB).withOpacity(0.1)),
              columns: const [
                DataColumn(label: Text('№')),
                DataColumn(label: Text('Мес')),
                DataColumn(label: Text('Месяц')),
                DataColumn(label: Text('Знач')),
                DataColumn(label: Text('Дата')),
                DataColumn(label: Text('X')),
              ],
              rows: List.generate(userMeasurements.length, (index) {
                final m = userMeasurements[index];
                final baseDate = childBirthDate!;
                final diffInDays = m.date.difference(baseDate).inDays;
                final monthsExact = diffInDays / 30.0;
                final developmentMonth = (diffInDays / 30.0).ceil();
                final dateStr = DateFormat('dd.MM.yy').format(m.date);
                final valueStr = m.type == MetricType.height ? '${m.value} см' : '${m.value} кг';
                return DataRow(
                  cells: [
                    DataCell(Text('${index + 1}', style: GoogleFonts.roboto(fontSize: 12))),
                    DataCell(Text('${monthsExact.toStringAsFixed(1)}', style: GoogleFonts.roboto(fontSize: 12))),
                    DataCell(Text('$developmentMonth мес.', style: GoogleFonts.roboto(fontSize: 12))),
                    DataCell(Text(valueStr, style: GoogleFonts.roboto(fontSize: 12))),
                    DataCell(Text(dateStr, style: GoogleFonts.roboto(fontSize: 12))),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 18),
                        onPressed: () {
                          setState(() {
                            userMeasurements.removeAt(index);
                          });
                          _saveData();
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
