import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

/// Пример AppColors – замените на свои реальные цвета, если необходимо
class AppColors {
  static const Color kMintDark = Color(0xFF00897B);
  static const Color kBackground = Color(0xFFF0F4F5);

  static const Color greenLine = Color(0xFF4CAF50); // официальные данные (норма, p50)
  static const Color blueLine  = Color(0xFF2196F3); // данные пользователя

  // Добавляем цвета для отклонений:
  static const Color redLine   = Color(0xFFFF5252);
  static const Color orangeLine = Color(0xFFFFA000);
}

/// Тип метрики (Рост / Вес)
enum MetricType { height, weight }

/// Модель замера (value изменяем для редактирования)
class UserMeasurement {
  late final DateTime date;
  double value;
  MetricType type;

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
      value: (json['value'] as num).toDouble(),
      type: MetricType.values[json['type']],
    );
  }
}

/// Примерные официальные данные (1..36) — рост (см)
final List<double> growthOfficialData = [
  50, 52, 54, 56, 58, 60, 61, 63, 64, 66, 68, 70, 72, 74, 75, 77,
  79, 80, 82, 84, 86, 88, 90, 92, 93, 94, 95, 96, 97, 98, 99, 100,
  100, 100, 100, 100
];

/// Примерные официальные данные (1..36) — вес (кг)
final List<double> weightOfficialData = [
  3.2, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 8.5, 9, 9.3, 9.7, 10,
  10.5, 11, 11.4, 12, 12.3, 13, 13.2, 14, 14.2, 14.5, 14.8, 15,
  15, 15, 15, 15, 15, 15, 15, 15,
  15
];

/// Основной экран
class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({Key? key}) : super(key: key);

  @override
  State<GrowthTrackingScreen> createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen> {
  DateTime? birthDate;
  MetricType selectedMetric = MetricType.weight;
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

  /// Сохранение данных
  Future<void> _saveData() async {
    final sp = await SharedPreferences.getInstance();
    if (birthDate != null) {
      sp.setString('gt_birth_date', birthDate!.toIso8601String());
    }
    final measJson = jsonEncode(measurements.map((m) => m.toJson()).toList());
    sp.setString('gt_measurements', measJson);
    sp.setInt('gt_metric', selectedMetric.index);
  }

  /// Загрузка данных
  Future<void> _loadData() async {
    final sp = await SharedPreferences.getInstance();
    final bdStr = sp.getString('gt_birth_date');
    if (bdStr != null) {
      birthDate = DateTime.tryParse(bdStr);
    }
    final measStr = sp.getString('gt_measurements');
    if (measStr != null) {
      final list = jsonDecode(measStr) as List;
      measurements.clear();
      measurements.addAll(list.map((j) => UserMeasurement.fromJson(j)));
    }
    final metricIdx = sp.getInt('gt_metric');
    if (metricIdx != null && metricIdx < MetricType.values.length) {
      selectedMetric = MetricType.values[metricIdx];
    }
    setState(() {});
  }

  /// Диалог выбора даты рождения (формат: дд ММММ гггг, месяц на русском)
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
                  'Дата рождения ребёнка',
                  style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
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
                      onDateTimeChanged: (picked) {
                        temp = picked;
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
                        setState(() {
                          birthDate = temp;
                        });
                        _saveData();
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
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

  /// Переключатель: Рост / Вес
  Widget _buildMetricSwitcher() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedMetric = MetricType.height;
            });
            _saveData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: (selectedMetric == MetricType.height)
                ? AppColors.kMintDark
                : Colors.white,
          ),
          child: Text(
            'Рост',
            style: TextStyle(
              color: (selectedMetric == MetricType.height)
                  ? Colors.white
                  : AppColors.kMintDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedMetric = MetricType.weight;
            });
            _saveData();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: (selectedMetric == MetricType.weight)
                ? AppColors.kMintDark
                : Colors.white,
          ),
          child: Text(
            'Вес',
            style: TextStyle(
              color: (selectedMetric == MetricType.weight)
                  ? Colors.white
                  : AppColors.kMintDark,
            ),
          ),
        ),
      ],
    );
  }

  /// Кнопка «Подробнее…» — показывает официальные данные (1..36)
  void _showDetailOfficialData() {
    final isWeight = (selectedMetric == MetricType.weight);
    final data = isWeight ? weightOfficialData : growthOfficialData;
    final unit = isWeight ? 'кг' : 'см';
    final title = isWeight ? 'Подробнее о весе' : 'Подробнее о росте';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width * 0.9,
            height: MediaQuery.of(ctx).size.height * 0.6,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isWeight
                        ? 'Ниже приведены примерные официальные данные по весу (1..36 мес).'
                        : 'Ниже приведены примерные официальные данные по росту (1..36 мес).',
                    style: GoogleFonts.roboto(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(36, (i) {
                    final m = i + 1;
                    final val = data[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        'В $m мес: $val $unit',
                        style: GoogleFonts.roboto(fontSize: 14),
                      ),
                    );
                  }),
                ],
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

  /// Диалог "Добавить замер"
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
                    selectedMetric == MetricType.weight ? 'Добавить вес' : 'Добавить рост',
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selectedMetric == MetricType.weight ? 'Вес (кг)' : 'Рост (см)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Дата: ',
                        style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        measureDate == null
                            ? 'не выбрана'
                            : DateFormat('dd MMMM yyyy', 'ru').format(measureDate!),
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
                              return Localizations.override(
                                context: c2,
                                locale: const Locale('ru', 'RU'),
                                child: Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: SizedBox(
                                    height: 300,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 12),
                                        Text(
                                          'Выберите дату замера',
                                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Expanded(
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode.date,
                                            initialDateTime: init,
                                            minimumDate: minD,
                                            maximumDate: now,
                                            onDateTimeChanged: (picked) {
                                              tmp = picked;
                                            },
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
                                              child: const Text('Ок'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
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
                          final raw = valCtrl.text.replaceAll(',', '.');
                          final parsed = double.tryParse(raw);
                          if (parsed == null) {
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
                          if (birthDate != null && measureDate!.isBefore(birthDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Дата не может быть раньше рождения')),
                            );
                            return;
                          }
                          if (measureDate!.isAfter(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Дата не может быть в будущем')),
                            );
                            return;
                          }
                          double finalVal = parsed;
                          if (selectedMetric == MetricType.weight) {
                            if (finalVal < 1) finalVal = 1;
                            if (finalVal > 30) finalVal = 30;
                          } else {
                            if (finalVal < 40) finalVal = 40;
                            if (finalVal > 120) finalVal = 120;
                          }
                          setState(() {
                            measurements.add(UserMeasurement(
                              date: measureDate!,
                              value: finalVal,
                              type: selectedMetric,
                            ));
                          });
                          _saveData();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
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

  /// Диалог "Редактировать замер"
  void _showEditMeasurementDialog(UserMeasurement um) {
    final valCtrl = TextEditingController(text: um.value.toString());
    DateTime measureDate = um.date;

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
                    selectedMetric == MetricType.weight ? 'Редактировать вес' : 'Редактировать рост',
                    style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: valCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: selectedMetric == MetricType.weight ? 'Вес (кг)' : 'Рост (см)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('Дата: ', style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w500)),
                      Text(
                        DateFormat('dd MMMM yyyy', 'ru').format(measureDate),
                        style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          final now = DateTime.now();
                          final init = measureDate;
                          final minD = birthDate ?? DateTime(1900);
                          showDialog(
                            context: context,
                            builder: (c2) {
                              DateTime tmp = init;
                              return Localizations.override(
                                context: c2,
                                locale: const Locale('ru', 'RU'),
                                child: Dialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: SizedBox(
                                    height: 300,
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 12),
                                        Text(
                                          'Выберите дату замера',
                                          style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                        Expanded(
                                          child: CupertinoDatePicker(
                                            mode: CupertinoDatePickerMode.date,
                                            initialDateTime: init,
                                            minimumDate: minD,
                                            maximumDate: now,
                                            onDateTimeChanged: (picked) {
                                              tmp = picked;
                                            },
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
                                              child: const Text('Ок'),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
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
                          final raw = valCtrl.text.replaceAll(',', '.');
                          final parsed = double.tryParse(raw);
                          if (parsed == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Неверный формат числа')),
                            );
                            return;
                          }
                          if (birthDate != null && measureDate.isBefore(birthDate!)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Дата не может быть раньше рождения')),
                            );
                            return;
                          }
                          if (measureDate.isAfter(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Дата не может быть в будущем')),
                            );
                            return;
                          }
                          double finalVal = parsed;
                          if (selectedMetric == MetricType.weight) {
                            if (finalVal < 1) finalVal = 1;
                            if (finalVal > 30) finalVal = 30;
                          } else {
                            if (finalVal < 40) finalVal = 40;
                            if (finalVal > 120) finalVal = 120;
                          }
                          setState(() {
                            um.value = finalVal;
                            um.date = measureDate;
                          });
                          _saveData();
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
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

  /// Построение графика (5 линий процентилей + пользовательская линия)
  Widget _buildChart() {
    // Для простоты в этом примере оставим использование growthOfficialData и weightOfficialData как единственной официальной линии.
    // Но ниже мы добавляем дополнительные горизонтальные линии для отклонений.
    final official = <FlSpot>[];
    double minY, maxY;
    if (selectedMetric == MetricType.weight) {
      minY = 1;
      maxY = 30;
      for (int i = 0; i < 36; i++) {
        official.add(FlSpot((i + 1).toDouble(), weightOfficialData[i]));
      }
    } else {
      minY = 40;
      maxY = 120;
      for (int i = 0; i < 36; i++) {
        official.add(FlSpot((i + 1).toDouble(), growthOfficialData[i]));
      }
    }

    final user = <FlSpot>[];
    if (birthDate != null) {
      final base = birthDate!;
      final filtered = measurements.where((m) => m.type == selectedMetric).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      for (final f in filtered) {
        final days = f.date.difference(base).inDays;
        double x = (days / 30.0).roundToDouble();
        if (x < 1) x = 1;
        if (x > 36) x = 36;
        double y = f.value;
        if (y < minY) y = minY;
        if (y > maxY) y = maxY;
        user.add(FlSpot(x, y));
      }
    }

    return LineChart(
      LineChartData(
        extraLinesData: ExtraLinesData(
          horizontalLines: selectedMetric == MetricType.weight
              ? [
            // Для веса: красные линии (значительное отклонение)
            HorizontalLine(
              y: 3,
              color: AppColors.redLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 16,
              color: AppColors.redLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            // Для веса: оранжевые линии (незначительное отклонение)
            HorizontalLine(
              y: 3.5,
              color: AppColors.orangeLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 15,
              color: AppColors.orangeLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ]
              : [
            // Для роста: красные линии
            HorizontalLine(
              y: 45,
              color: AppColors.redLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 105,
              color: AppColors.redLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            // Для роста: оранжевые линии
            HorizontalLine(
              y: 50,
              color: AppColors.orangeLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
            HorizontalLine(
              y: 100,
              color: AppColors.orangeLine,
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ],
        ),
        minX: 1,
        maxX: 36,
        minY: minY,
        maxY: maxY,
        clipData: const FlClipData.all(),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((barSpot) {
                final val = barSpot.y.toStringAsFixed(1);
                final xM = barSpot.x.toStringAsFixed(0);
                return LineTooltipItem(
                  '$val\n$xM',
                  const TextStyle(color: Colors.black),
                );
              }).toList();
            },
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: selectedMetric == MetricType.weight
                ? const Text('Месяц (вес)')
                : const Text('Месяц (рост)'),
            axisNameSize: 18,
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (val, meta) {
                if (val >= 1 && val <= 36 && val % 1 == 0) {
                  // Поворачиваем подписи на -90° и выводим только число
                  return Transform.rotate(
                    angle: -math.pi / 2,
                    child: Text('${val.toInt()}', style: const TextStyle(fontSize: 10)),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: selectedMetric == MetricType.weight
                ? const Text('Вес (кг)')
                : const Text('Рост (см)'),
            axisNameSize: 18,
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                if (selectedMetric == MetricType.weight) {
                  final v = val.round();
                  if (v < 1 || v > 30) return const SizedBox();
                  if (v % 2 == 0) return Text('$v', style: const TextStyle(fontSize: 10));
                  return const SizedBox();
                } else {
                  final v = val.round();
                  if (v < 40 || v > 120) return const SizedBox();
                  if (v % 5 == 0) return Text('$v', style: const TextStyle(fontSize: 10));
                  return const SizedBox();
                }
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: selectedMetric == MetricType.weight ? 2 : 5,
          verticalInterval: 1,
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          // Официальная линия – зелёная (p50)
          LineChartBarData(
            spots: official,
            isCurved: true,
            color: AppColors.greenLine,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
          // Пользовательская линия – синяя
          LineChartBarData(
            spots: user,
            isCurved: false,
            color: AppColors.blueLine,
            barWidth: 3,
            dotData: FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  /// Список замеров
  Widget _buildMeasurementsList() {
    final filtered = measurements.where((m) => m.type == selectedMetric).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    if (filtered.isEmpty) {
      return Container(
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
        child: const Center(child: Text('Нет данных. Нажмите «Добавить…»')),
      );
    }
    final df = DateFormat('dd MMMM yyyy', 'ru');
    return Container(
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
                  selectedMetric == MetricType.weight ? 'Вес (кг)' : 'Рост (см)',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: Text(
                  'Дата',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 80),
            ],
          ),
          const Divider(),
          ListView.builder(
            itemCount: filtered.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (ctx, i) {
              final item = filtered[i];
              final dateStr = df.format(item.date);
              final valStr = selectedMetric == MetricType.weight ? '${item.value} кг' : '${item.value} см';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(valStr)),
                    Expanded(child: Text(dateStr)),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditMeasurementDialog(item);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          measurements.removeWhere((m) =>
                          m.date == item.date &&
                              m.value == item.value &&
                              m.type == item.type);
                        });
                        _saveData();
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noBirth = (birthDate == null);
    return Scaffold(
      backgroundColor: AppColors.kBackground,
      appBar: AppBar(
        title: const Text('Рост / Вес ребёнка'),
        centerTitle: true,
        backgroundColor: AppColors.kMintDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Выбрать дату рождения',
            onPressed: _showBirthDateDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: noBirth
            ? Center(
          child: ElevatedButton(
            onPressed: _showBirthDateDialog,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
            child: const Text('Выбрать дату рождения'),
          ),
        )
            : SingleChildScrollView(
          child: Column(
            children: [
              // Карточка с графиком
              Container(
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
                      _buildMetricSwitcher(),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showDetailOfficialData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.kMintDark, width: 1),
                        ),
                        child: Text(
                          selectedMetric == MetricType.weight ? 'Подробнее о весе' : 'Подробнее о росте',
                          style: const TextStyle(color: AppColors.kMintDark),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showAddMeasurementDialog,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.kMintDark),
                        child: Text(
                          selectedMetric == MetricType.weight ? 'Добавить вес' : 'Добавить рост',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Список замеров
              _buildMeasurementsList(),
            ],
          ),
        ),
      ),
    );
  }
}
