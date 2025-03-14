import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/// Цвета
const Color kBackground = Color(0xFFF4F8F8);
const Color kMintDark = Color(0xFF009688);

/// Класс для 5 перцентилей (p3..p97)
class WhoDataFull {
  final double month;
  final double p3;
  final double p15;
  final double p50;
  final double p85;
  final double p97;

  WhoDataFull(
      this.month,
      this.p3,
      this.p15,
      this.p50,
      this.p85,
      this.p97,
      );
}

/// Тип метрики (Рост / Вес)
enum MetricType { height, weight }

/// Модель пользовательского замера
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

// Примерные данные ВОЗ — рост
final List<WhoDataFull> whoHeightData36 = [
  WhoDataFull(1, 49, 50.5, 52, 53.5, 55),
  WhoDataFull(2, 53, 54, 56, 58, 59.5),
  WhoDataFull(3, 55, 56, 59, 61, 62.5),
  WhoDataFull(4, 56.5, 58, 61, 63.2, 64.7),
  WhoDataFull(5, 58, 59.5, 62.5, 65, 66.5),
  WhoDataFull(6, 59, 60.5, 64, 66.5, 68),
  WhoDataFull(7, 60, 61.5, 65, 67.8, 69.5),
  WhoDataFull(8, 61, 62.5, 66.2, 69, 70.5),
  WhoDataFull(9, 62, 63.5, 67.4, 70.2, 71.8),
  WhoDataFull(10, 63, 64.5, 68.5, 71.5, 73),
  WhoDataFull(11, 64, 65.5, 69.5, 72.5, 74),
  WhoDataFull(12, 65, 66.5, 70.5, 73.7, 75.2),
  WhoDataFull(15, 68, 69.5, 74, 77, 78.5),
  WhoDataFull(18, 71, 72.5, 77, 80, 82),
  WhoDataFull(24, 76, 77.5, 83, 86, 88),
  WhoDataFull(30, 80, 81.5, 88, 91, 93),
  WhoDataFull(36, 85, 86.5, 93, 96, 98),
];

// Примерные данные ВОЗ — вес
final List<WhoDataFull> whoWeightData36 = [
  WhoDataFull(1, 3.2, 3.6, 4.3, 4.9, 5.4),
  WhoDataFull(2, 4.0, 4.3, 5.4, 6.0, 6.5),
  WhoDataFull(3, 4.6, 5.1, 6.2, 6.9, 7.4),
  WhoDataFull(4, 5.0, 5.5, 6.7, 7.5, 8.0),
  WhoDataFull(5, 5.4, 5.9, 7.2, 7.9, 8.5),
  WhoDataFull(6, 5.7, 6.3, 7.6, 8.4, 8.9),
  WhoDataFull(7, 6.0, 6.6, 8.0, 8.8, 9.3),
  WhoDataFull(8, 6.3, 6.9, 8.3, 9.2, 9.6),
  WhoDataFull(9, 6.5, 7.1, 8.6, 9.5, 9.9),
  WhoDataFull(10, 6.7, 7.3, 8.8, 9.7, 10.2),
  WhoDataFull(12, 7.1, 7.8, 9.3, 10.2, 10.7),
  WhoDataFull(15, 7.8, 8.3, 10.0, 10.9, 11.4),
  WhoDataFull(18, 8.4, 8.9, 10.8, 11.6, 12.1),
  WhoDataFull(24, 10.0, 11.0, 13.0, 14.0, 15.0),
  WhoDataFull(30, 11.5, 12.0, 14.5, 16.0, 17.0),
  WhoDataFull(36, 12.5, 13.5, 16.0, 18.0, 19.0),
];

class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({Key? key}) : super(key: key);

  @override
  State<GrowthTrackingScreen> createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen> {
  DateTime? birthDate;
  MetricType selectedMetric = MetricType.height;
  final List<UserMeasurement> measurements = [];

  @override
  void initState() {
    super.initState();
    _loadData().then((_) {
      if (birthDate == null) {
        _showBirthDateDialog();
      }
    });
  }

  Future<void> _saveData() async {
    final sp = await SharedPreferences.getInstance();
    if (birthDate != null) {
      sp.setString('birth_date', birthDate!.toIso8601String());
    }
    final measJson = jsonEncode(measurements.map((m) => m.toJson()).toList());
    sp.setString('measurements', measJson);
    sp.setInt('metric', selectedMetric.index);
  }

  Future<void> _loadData() async {
    final sp = await SharedPreferences.getInstance();
    final bdStr = sp.getString('birth_date');
    if (bdStr != null) {
      birthDate = DateTime.tryParse(bdStr);
    }
    final measStr = sp.getString('measurements');
    if (measStr != null) {
      final list = jsonDecode(measStr) as List;
      measurements.clear();
      measurements.addAll(list.map((j) => UserMeasurement.fromJson(j)));
    }
    final metricIdx = sp.getInt('metric');
    if (metricIdx != null && metricIdx < MetricType.values.length) {
      selectedMetric = MetricType.values[metricIdx];
    }
    setState(() {});
  }

  /// Диалог даты рождения
  void _showBirthDateDialog() {
    final now = DateTime.now();
    final init = birthDate ?? DateTime(now.year - 1, now.month, now.day);
    showDialog(
      context: context,
      builder: (ctx) {
        DateTime temp = init;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            height: 320,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Text(
                  'Укажите дату рождения ребёнка',
                  style:
                  GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Localizations.override(
                    context: ctx,
                    locale: const Locale('ru', 'RU'),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: temp,
                      minimumDate: DateTime(1900),
                      maximumDate: now,
                      onDateTimeChanged: (picked) => temp = picked,
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
                        setState(() {
                          birthDate = temp;
                        });
                        _saveData();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: kMintDark),
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

  /// BottomSheet добавления замера
  void _showAddMeasurementDialog() {
    final valCtrl = TextEditingController();
    DateTime? measureDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setStateSB) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    (selectedMetric == MetricType.height)
                        ? 'Добавить новое значение роста'
                        : 'Добавить новое значение веса',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valCtrl,
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
                      Text(
                        'Дата: ',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        (measureDate == null)
                            ? 'не выбрана'
                            : DateFormat('dd.MM.yyyy').format(measureDate!),
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          final init = measureDate ?? now;
                          final minD = birthDate ?? DateTime(1900);
                          showDialog(
                            context: context,
                            builder: (c2) {
                              DateTime tmp = init;
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 300,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                        'Выберите дату замера',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Expanded(
                                        child: Localizations.override(
                                          context: c2,
                                          locale: const Locale('ru', 'RU'),
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode.date,
                                            initialDateTime: init,
                                            minimumDate: minD,
                                            maximumDate: now,
                                            onDateTimeChanged: (picked) =>
                                            tmp = picked,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(c2),
                                            child: const Text('Отмена'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setStateSB(() {
                                                measureDate = tmp;
                                              });
                                              Navigator.pop(c2);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kMintDark,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Ок'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kMintDark),
                        child: const Text('Выбрать дату'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final val = double.tryParse(valCtrl.text);
                          if (val == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Неверный формат числа')),
                            );
                            return;
                          }
                          if (measureDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Дата не выбрана')),
                            );
                            return;
                          }
                          if (birthDate != null &&
                              measureDate!.isBefore(birthDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Дата не может быть раньше рождения',
                                ),
                              ),
                            );
                            return;
                          }
                          if (measureDate!.isAfter(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Дата не может быть в будущем'),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            measurements.add(
                              UserMeasurement(
                                date: measureDate!,
                                value: val,
                                type: selectedMetric,
                              ),
                            );
                          });
                          _saveData();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kMintDark),
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  /// Диалог "Подробнее..." (обновлённая версия с описанием "с X по Y месяц")
  void _showDetailDialog() {
    final isHeight = (selectedMetric == MetricType.height);
    final title = isHeight ? 'Подробнее про рост' : 'Подробнее про вес';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            // Задаём ограничение по высоте для нормального скролла
            height: MediaQuery.of(ctx).size.height * 0.6,
            width: MediaQuery.of(ctx).size.width * 0.9,
            // Одинарный ScrollView без вложенностей
            child: SingleChildScrollView(
              child: Column(
                children: _buildDetailWidgets(isHeight),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  /// Генерация списка текстовых виджетов по периодам из whoData
  List<Widget> _buildDetailWidgets(bool isHeight) {
    final data = isHeight ? whoHeightData36 : whoWeightData36;
    final units = isHeight ? 'см' : 'кг';
    final items = <Widget>[];

    // Пробегаемся по всем записям (p3..p97) и делаем красивый текст:
    // "В период с X по Y месяц: примерно от p3..p97, (p50 ~ ...)"
    // Или, если хотим упрощённо, можно выводить только p50. Но ниже пример с диапазоном:
    for (int i = 0; i < data.length - 1; i++) {
      final fromM = data[i].month.toInt();
      final toM = data[i + 1].month.toInt();

      final fromP3 = data[i].p3.toStringAsFixed(1);
      final toP97 = data[i + 1].p97.toStringAsFixed(1);
      final p50Avg = data[i].p50.toStringAsFixed(1);

      final textLine =
          'В период с $fromM по $toM мес: от $fromP3 до $toP97 $units (среднее ~$p50Avg $units).';
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            textLine,
            style: GoogleFonts.roboto(fontSize: 14),
          ),
        ),
      );
    }

    // Дополнительно можем вывести последнюю точку (36 мес), если нужно:
    // (Например, "После 36 мес примерно: ...")
    final last = data.last;
    if (last.month < 36) {
      // логика, если хотим добить до 36
    } else if (last.month == 36) {
      final p3 = last.p3.toStringAsFixed(1);
      final p97 = last.p97.toStringAsFixed(1);
      final p50 = last.p50.toStringAsFixed(1);
      items.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            'В период около 36 мес: от $p3 до $p97 $units (среднее ~$p50 $units).',
            style: GoogleFonts.roboto(fontSize: 14),
          ),
        ),
      );
    }

    return items;
  }

  /// Данные ВОЗ
  List<WhoDataFull> get whoData =>
      (selectedMetric == MetricType.height) ? whoHeightData36 : whoWeightData36;

  List<FlSpot> get p3Spots => whoData.map((d) => FlSpot(d.month, d.p3)).toList();
  List<FlSpot> get p15Spots =>
      whoData.map((d) => FlSpot(d.month, d.p15)).toList();
  List<FlSpot> get p50Spots =>
      whoData.map((d) => FlSpot(d.month, d.p50)).toList();
  List<FlSpot> get p85Spots =>
      whoData.map((d) => FlSpot(d.month, d.p85)).toList();
  List<FlSpot> get p97Spots =>
      whoData.map((d) => FlSpot(d.month, d.p97)).toList();

  /// Точки пользователя
  List<FlSpot> get userFlSpots {
    if (birthDate == null) return [];
    final base = birthDate!;
    final filtered =
    measurements.where((m) => m.type == selectedMetric).toList();
    filtered.sort((a, b) => a.date.compareTo(b.date));

    return filtered.map((m) {
      final diffDays = m.date.difference(base).inDays;
      double x = diffDays / 30.0;
      if (x < 1) x = 1;
      if (x > 36) x = 36;
      return FlSpot(x, m.value);
    }).toList();
  }

  /// График
  Widget _buildChart() {
    final isHeight = (selectedMetric == MetricType.height);
    final double minY = isHeight ? 40 : 2;
    final double maxY = isHeight ? 120 : 20;

    return SizedBox(
      width: 1100,
      child: LineChart(
        LineChartData(
          minX: 1,
          maxX: 36,
          minY: minY,
          maxY: maxY,
          clipData: const FlClipData.all(),
          backgroundColor: Colors.white,
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 10,
              getTooltipItems: (touchedSpots) {
                // пользовательская линия = barIndex=5
                final userSpots =
                touchedSpots.where((s) => s.barIndex == 5).toList();
                if (userSpots.isEmpty) return [];
                return userSpots.map((barSpot) {
                  final xVal = barSpot.x;
                  final yVal = barSpot.y;
                  return LineTooltipItem(
                    'Месяц: ${xVal.toStringAsFixed(0)}\nЗнач: ${yVal.toStringAsFixed(1)}',
                    GoogleFonts.roboto(fontSize: 14, color: Colors.black),
                  );
                }).toList();
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              axisNameWidget: Text(
                isHeight ? 'Рост (см)' : 'Вес (кг)',
                style:
                GoogleFonts.roboto(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              axisNameSize: 16,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (value, meta) {
                  if (isHeight) {
                    if (value % 5 == 0 && value >= 40 && value <= 120) {
                      return Text(value.toStringAsFixed(0));
                    }
                  } else {
                    if (value % 2 == 0 && value >= 2 && value <= 20) {
                      return Text(value.toStringAsFixed(0));
                    }
                  }
                  return const SizedBox();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Возраст (полных месяцев)'),
              axisNameSize: 16,
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50,
                getTitlesWidget: (value, meta) {
                  if (value >= 1 && value <= 36 && value % 1 == 0) {
                    return Transform.rotate(
                      angle: -math.pi / 2,
                      child: Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 11),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: isHeight ? 5 : 2,
            verticalInterval: 1,
            getDrawingHorizontalLine: (val) => FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
            getDrawingVerticalLine: (val) => FlLine(
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
            // p3
            LineChartBarData(
              spots: p3Spots,
              isCurved: true,
              color: Colors.red,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // p15
            LineChartBarData(
              spots: p15Spots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // p50
            LineChartBarData(
              spots: p50Spots,
              isCurved: true,
              color: Colors.green,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // p85
            LineChartBarData(
              spots: p85Spots,
              isCurved: true,
              color: Colors.orange,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // p97
            LineChartBarData(
              spots: p97Spots,
              isCurved: true,
              color: Colors.red,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
            // пользовательские точки (индекс=5)
            LineChartBarData(
              spots: userFlSpots,
              isCurved: false,
              color: const Color(0xFF00B4AB),
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, _, __, ___) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF00B4AB),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Карточка с графиком и кнопками
  Widget _buildChartCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            SizedBox(height: 400, child: _buildChart()),
            const SizedBox(height: 8),

            // Переключатель (2 кнопки)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (selectedMetric == MetricType.height)
                  _buildActiveButton('Рост')
                else
                  _buildInactiveButton('Рост', onTap: () {
                    setState(() {
                      selectedMetric = MetricType.height;
                    });
                    _saveData();
                  }),
                const SizedBox(width: 10),
                if (selectedMetric == MetricType.weight)
                  _buildActiveButton('Вес')
                else
                  _buildInactiveButton('Вес', onTap: () {
                    setState(() {
                      selectedMetric = MetricType.weight;
                    });
                    _saveData();
                  }),
              ],
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _showDetailDialog,
              style: ElevatedButton.styleFrom(
                foregroundColor: kMintDark,
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: kMintDark),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                (selectedMetric == MetricType.height)
                    ? 'Подробнее про рост'
                    : 'Подробнее про вес',
                style:
                GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton(
              onPressed: _showAddMeasurementDialog,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF00B4AB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                (selectedMetric == MetricType.height)
                    ? 'Добавить новое значение роста'
                    : 'Добавить новое значение веса',
                style:
                GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Активная кнопка
  Widget _buildActiveButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00B4AB), Color(0xFF009688)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(2, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Неактивная кнопка
  Widget _buildInactiveButton(String text, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: kMintDark, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: kMintDark,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Список замеров (таблица)
  Widget _buildMeasurementsList() {
    final filtered = measurements.where((m) => m.type == selectedMetric).toList();
    if (filtered.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            'Нет данных. Нажмите «Добавить новое значение…»',
            style: GoogleFonts.roboto(fontSize: 14),
          ),
        ),
      );
    }
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              offset: const Offset(2, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    (selectedMetric == MetricType.height) ? 'Рост' : 'Вес',
                    style:
                    GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Дата',
                    style:
                    GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 60),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final item = filtered[i];
                  final dateStr = DateFormat('dd.MM.yyyy').format(item.date);
                  final valStr = (item.type == MetricType.height)
                      ? '${item.value} см'
                      : '${item.value} кг';

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(valStr)),
                        Expanded(child: Text(dateStr)),
                        // Кнопка «Редактировать»
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editMeasurementDialog(i);
                          },
                        ),
                        // Кнопка «Удалить»
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              filtered.removeAt(i);
                            });
                            measurements.clear();
                            measurements.addAll(filtered);
                            _saveData();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Диалог редактирования замера
  void _editMeasurementDialog(int index) {
    final item = measurements[index];
    final valCtrl = TextEditingController(text: item.value.toStringAsFixed(1));
    DateTime measureDate = item.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setStateSB) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Редактировать замер',
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: (item.type == MetricType.height)
                          ? 'Рост (см)'
                          : 'Вес (кг)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Дата: '),
                      Text(DateFormat('dd.MM.yyyy').format(measureDate)),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          final minD = birthDate ?? DateTime(1900);
                          showDialog(
                            context: context,
                            builder: (c2) {
                              DateTime tmp = measureDate;
                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: SizedBox(
                                  height: 300,
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                        'Выберите дату',
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Expanded(
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          initialDateTime: tmp,
                                          minimumDate: minD,
                                          maximumDate: now,
                                          onDateTimeChanged: (picked) =>
                                          tmp = picked,
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                        children: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(c2),
                                            child: const Text('Отмена'),
                                          ),
                                          ElevatedButton(
                                            onPressed: () {
                                              setStateSB(() {
                                                measureDate = tmp;
                                              });
                                              Navigator.pop(c2);
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: kMintDark,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text('Ок'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: kMintDark),
                        child: const Text('Выбрать дату'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Отмена'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          final val = double.tryParse(valCtrl.text);
                          if (val == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Неверный формат числа')),
                            );
                            return;
                          }
                          if (birthDate != null &&
                              measureDate.isBefore(birthDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Дата не может быть раньше рождения',
                                ),
                              ),
                            );
                            return;
                          }
                          if (measureDate.isAfter(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Дата не может быть в будущем'),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            measurements[index] = UserMeasurement(
                              date: measureDate,
                              value: val,
                              type: item.type,
                            );
                          });
                          _saveData();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kMintDark,
                        ),
                        child: const Text('Сохранить'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final noBirthDate = (birthDate == null);
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: Text(
          'График роста/веса',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: kMintDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'Изменить дату рождения',
            onPressed: _showBirthDateDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: noBirthDate
            ? Center(
          child: ElevatedButton(
            onPressed: _showBirthDateDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: kMintDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Указать дату рождения'),
          ),
        )
            : Column(
          children: [
            _buildChartCard(),
            _buildMeasurementsList(),
          ],
        ),
      ),
    );
  }
}
