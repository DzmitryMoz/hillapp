import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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

/// Пример данных ВОЗ
class WhoDataPoint {
  final double month; // возраст в месяцах
  final double p50;   // 50-й перцентиль

  WhoDataPoint(this.month, this.p50);
}

// Данные ВОЗ для роста
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

// Данные ВОЗ для веса
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

/// Фон/тема
const Color kBackground = Color(0xFFE7F7F7);
const Color kMintDark = Color(0xFF00B4AB);

class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({Key? key}) : super(key: key);

  @override
  State<GrowthTrackingScreen> createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen>
    with SingleTickerProviderStateMixin {
  DateTime? childBirthDate;
  MetricType selectedMetric = MetricType.height;
  final List<UserMeasurement> userMeasurements = [];
  final TextEditingController _valueController = TextEditingController();

  // Анимация для пользовательской линии
  late AnimationController _lineAnimCtrl;
  late Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (childBirthDate == null) {
        _showBirthDateDialog();
      }
    });

    // Для анимации появления пользовательской кривой
    _lineAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _lineAnim = CurvedAnimation(parent: _lineAnimCtrl, curve: Curves.easeOutQuad);

    // Запустим анимацию сразу (можно запускать при setState, когда обновляются данные)
    _lineAnimCtrl.forward();
  }

  @override
  void dispose() {
    _lineAnimCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (childBirthDate != null) {
      await prefs.setString('birth_date', childBirthDate!.toIso8601String());
    }
    final measurementsJson =
    jsonEncode(userMeasurements.map((m) => m.toJson()).toList());
    await prefs.setString('measurements', measurementsJson);
  }

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
    setState(() {});
  }

  /// Диалог выбора даты рождения ребёнка
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
        _saveData();
      },
    );
  }

  /// Диалог добавления нового замера
  void _showAddMeasurementDialog() {
    _valueController.clear();
    DateTime? measurementDate;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text(
              (selectedMetric == MetricType.height)
                  ? 'Добавить показатель роста'
                  : 'Добавить показатель веса',
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _valueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: (selectedMetric == MetricType.height)
                        ? 'Рост (см)'
                        : 'Вес (кг)',
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
                  child: const Text('Выбрать дату'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Отмена'),
              ),
              ElevatedButton(
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
                  if (childBirthDate != null &&
                      measurementDate!.isBefore(childBirthDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Дата не может быть раньше рождения'),
                      ),
                    );
                    return;
                  }
                  if (measurementDate!.isAfter(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Дата не может быть в будущем'),
                      ),
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
                  _saveData();
                  Navigator.pop(ctx);

                  // Перезапускаем анимацию линии
                  _lineAnimCtrl.forward(from: 0.0);
                },
                child: const Text('Сохранить'),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Универсальный диалог с CupertinoDatePicker
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SizedBox(
            height: 300,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Localizations.override(
                    context: context,
                    locale: const Locale('ru', 'RU'),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: tempDate,
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
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        onDateSaved(tempDate);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Сохранить'),
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

  /// Таблица показателей
  Widget _buildMeasurementsTable() {
    final filtered = userMeasurements
        .where((m) => m.type == selectedMetric)
        .toList();

    final valueColTitle =
    (selectedMetric == MetricType.height) ? 'Рост' : 'Вес';

    if (filtered.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('Нет данных. Нажмите «Добавить» выше.'),
      );
    }

    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 16,
            headingRowColor: MaterialStateProperty.all(
              kMintDark.withOpacity(0.1),
            ),
            columns: [
              const DataColumn(label: Text('№')),
              const DataColumn(label: Text('Возраст\n(мес)')),
              DataColumn(label: Text(valueColTitle)),
              const DataColumn(label: Text('Дата')),
              const DataColumn(label: Text('')),
            ],
            rows: List.generate(filtered.length, (index) {
              final m = filtered[index];
              final baseDate = childBirthDate!;
              final diffDays = m.date.difference(baseDate).inDays;
              final monthsExact = diffDays / 30.0;
              final dateStr = DateFormat('dd.MM.yy').format(m.date);

              final valStr = (m.type == MetricType.height)
                  ? '${m.value} см'
                  : '${m.value} кг';

              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text('${monthsExact.toStringAsFixed(1)}')),
                  DataCell(Text(valStr)),
                  DataCell(Text(dateStr)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          userMeasurements.remove(filtered[index]);
                        });
                        _saveData();
                        _lineAnimCtrl.forward(from: 0.0);
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Выбор метрики (рост/вес)
  Widget _buildMetricPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Метрика:',
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.black87)),
        const SizedBox(width: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DropdownButton<MetricType>(
              value: selectedMetric,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: MetricType.height,
                  child: Text('Рост'),
                ),
                DropdownMenuItem(
                  value: MetricType.weight,
                  child: Text('Вес'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedMetric = val;
                  });
                  // Перезапустим анимацию
                  _lineAnimCtrl.forward(from: 0.0);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Улучшенный график
  Widget _buildChartCard() {
    final maxY = (selectedMetric == MetricType.height) ? 120.0 : 20.0;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        height: 320,
        padding: const EdgeInsets.all(16),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: 36,
            minY: 0,
            maxY: maxY,
            clipData: const FlClipData.all(),
            backgroundColor: Colors.white,
            lineTouchData: LineTouchData(
              enabled: true,
              touchTooltipData: LineTouchTooltipData(
                tooltipRoundedRadius: 12,
                getTooltipItems: (spots) => spots.map((barSpot) {
                  final month = barSpot.x;
                  final val = barSpot.y;
                  return LineTooltipItem(
                    'Месяц: ${month.toStringAsFixed(1)}\n'
                        'Знач: ${val.toStringAsFixed(1)}',
                    GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList(),
              ),
            ),
            // Оси
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                axisNameWidget: Text(
                  (selectedMetric == MetricType.height)
                      ? 'Рост (см)'
                      : 'Вес (кг)',
                  style: GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                axisNameSize: 20,
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 34,
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
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            // Сетка
            gridData: FlGridData(
              show: true,
              horizontalInterval: (selectedMetric == MetricType.height) ? 10 : 2,
              verticalInterval: 6,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.shade300,
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300),
            ),
            lineBarsData: [
              // Линия ВОЗ (dash effect)
              LineChartBarData(
                spots: whoSpots,
                isCurved: false,
                color: Colors.grey.shade600,
                barWidth: 2,
                dashArray: [8, 8],
              ),
              // Линия пользовательских замеров (with animation)
              LineChartBarData(
                spots: _animatedSpots(),
                isCurved: true,
                color: kMintDark,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) {
                    // Анимация “пульса” для точек (scale based on _lineAnim)
                    final double scale = 1.0 + 0.2 * (1 - _lineAnim.value);
                    return FlDotCirclePainter(
                      radius: 4 * scale,
                      color: kMintDark,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    colors: [
                      kMintDark.withOpacity(0.3),
                      kMintDark.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Animated spots для пользовательских замеров
  /// В зависимости от _lineAnim.value (0..1) меняем Y
  List<FlSpot> _animatedSpots() {
    final original = userSpots;
    // При _lineAnim.value = 0 => все точки = 0,
    // при 1 => все точки = userSpots
    return original.map((spot) {
      final double newY = spot.y * _lineAnim.value;
      return FlSpot(spot.x, newY);
    }).toList();
  }

  /// Подписи оси X (fl_chart)
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value >= 0 && value <= 36 && value % 6 == 0) {
      return Text(
        value.toStringAsFixed(0),
        style: GoogleFonts.roboto(fontSize: 10),
      );
    }
    return const SizedBox();
  }

  /// Подписи оси Y (fl_chart)
  Widget _buildLeftTitle(double value, TitleMeta meta) {
    if (selectedMetric == MetricType.height) {
      if (value % 10 == 0 && value >= 0 && value <= 120) {
        return Text(
          value.toStringAsFixed(0),
          style: GoogleFonts.roboto(fontSize: 10),
        );
      }
    } else {
      if (value % 2 == 0 && value >= 0 && value <= 20) {
        return Text(
          value.toStringAsFixed(0),
          style: GoogleFonts.roboto(fontSize: 10),
        );
      }
    }
    return const SizedBox();
  }

  /// Данные ВОЗ
  List<FlSpot> get whoSpots {
    final data = (selectedMetric == MetricType.height) ? whoHeightBoys : whoWeightBoys;
    return data.map((dp) => FlSpot(dp.month, dp.p50)).toList();
  }

  /// Точки пользовательских замеров
  List<FlSpot> get userSpots {
    if (childBirthDate == null) return [];
    final base = childBirthDate!;
    final filtered = userMeasurements.where((m) => m.type == selectedMetric).toList();
    return filtered.map((m) {
      final diffDays = m.date.difference(base).inDays;
      final months = diffDays / 30.0;
      return FlSpot(months, m.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final hasDate = (childBirthDate != null);

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Рост / Вес ребёнка'),
        backgroundColor: kMintDark,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Карточка с датой рождения
              _buildBirthDateCard(),
              const SizedBox(height: 16),

              if (hasDate) ...[
                _buildChartCard(),
                _buildMetricPicker(),
                const SizedBox(height: 16),
                _buildMeasurementsTable(),
              ],
            ],
          ),
        ),
      ),

      // Заменяем FAB на "фенси" градиентную кнопку
      floatingActionButton: hasDate
          ? _buildFancyGradientButton(
        label: 'Добавить',
        icon: Icons.add,
        onTap: _showAddMeasurementDialog,
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  /// Карточка с датой рождения
  Widget _buildBirthDateCard() {
    if (childBirthDate == null) {
      return _neumorphicCard(
        child: ListTile(
          leading: const Icon(Icons.cake_outlined, color: kMintDark),
          title: Text(
            'Укажите дату рождения',
            style: GoogleFonts.roboto(fontSize: 16),
          ),
          subtitle: Text(
            'Нажмите, чтобы выбрать',
            style: GoogleFonts.roboto(fontSize: 12),
          ),
          onTap: _showBirthDateDialog,
        ),
      );
    } else {
      final dateStr = DateFormat('dd.MM.yyyy').format(childBirthDate!);
      return _neumorphicCard(
        child: ListTile(
          leading: const Icon(Icons.cake, color: kMintDark),
          title: Text(
            'Дата рождения: $dateStr',
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            'Нажмите, чтобы изменить',
            style: GoogleFonts.roboto(fontSize: 12),
          ),
          onTap: _showBirthDateDialog,
        ),
      );
    }
  }

  /// Простая "неоморфная" обёртка
  Widget _neumorphicCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Мягкие тени
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(-3, -3),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Colors.grey.shade500,
            offset: const Offset(3, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }

  /// Градиентная «фенси» кнопка (замена FAB)
  Widget _buildFancyGradientButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00B4AB), Color(0xFF82E9DE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.roboto(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
