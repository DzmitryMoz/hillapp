import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // для CupertinoDatePicker
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Тип метрики: рост или вес
enum MetricType { height, weight }

/// Модель данных для пользовательских замеров
class UserMeasurement {
  final DateTime date;
  final double value;    // значение (либо рост, либо вес)
  final MetricType type; // какой показатель

  UserMeasurement({
    required this.date,
    required this.value,
    required this.type,
  });
}

/// Пример данных ВОЗ (укороченный)
class WhoDataPoint {
  final double month; // возраст в месяцах
  final double p50;   // 50-й перцентиль (средний)

  WhoDataPoint(this.month, this.p50);
}

/// Рост (см) мальчиков
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

/// Вес (кг) мальчиков
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

class GrowthTrackingScreen extends StatefulWidget {
  const GrowthTrackingScreen({Key? key}) : super(key: key);

  @override
  _GrowthTrackingScreenState createState() => _GrowthTrackingScreenState();
}

class _GrowthTrackingScreenState extends State<GrowthTrackingScreen> {
  /// Дата рождения ребёнка
  DateTime? childBirthDate;

  /// Текущая метрика (рост или вес)
  MetricType selectedMetric = MetricType.height;

  /// Список пользовательских замеров
  final List<UserMeasurement> userMeasurements = [];

  /// Контроллер для ввода значения
  final TextEditingController _valueController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Если при входе дата рождения не установлена, сразу просим выбрать
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (childBirthDate == null) {
        _showBirthDateDialog();
      }
    });
  }

  /// Показать диалог с CupertinoDatePicker (год/месяц/день) по центру
  /// с кнопками "Отмена" и "Сохранить".
  ///
  /// Параметры:
  /// - title: заголовок
  /// - initialDate: начальная дата для пикера
  /// - minDate, maxDate: ограничения
  /// - onDateSaved: что делать, когда нажмём "Сохранить"
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
        // Для центрирования используем Dialog + Column
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: SizedBox(
            height: 380,
            child: Column(
              children: [
                // Заголовок
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                // Сам CupertinoDatePicker
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initialDate,
                    minimumDate: minDate,
                    maximumDate: maxDate,
                    onDateTimeChanged: (picked) {
                      // Запоминаем локально
                      initialDate = picked;
                    },
                  ),
                ),
                // Кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Отмена'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
                      onPressed: () {
                        onDateSaved(initialDate);
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

  /// Показать диалог для выбора даты рождения ребёнка
  void _showBirthDateDialog() {
    final now = DateTime.now();
    final initial = childBirthDate ?? DateTime(now.year - 1, now.month, now.day);
    _showCenteredDatePicker(
      title: 'Выберите дату рождения ребёнка',
      initialDate: initial,
      minDate: DateTime(1900),
      maxDate: now,
      onDateSaved: (pickedDate) {
        setState(() {
          childBirthDate = pickedDate;
        });
      },
    );
  }

  /// Диалог добавления нового замера (рост/вес)
  void _showAddMeasurementDialog() {
    _valueController.clear();
    DateTime? measurementDate;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                selectedMetric == MetricType.height
                    ? 'Добавить показатель роста'
                    : 'Добавить показатель веса',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Поле ввода числового значения
                  TextField(
                    controller: _valueController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: (selectedMetric == MetricType.height) ? 'Рост (см)' : 'Вес (кг)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Дата замера
                  Row(
                    children: [
                      const Text('Дата замера: '),
                      Text(
                        measurementDate == null
                            ? 'не выбрана'
                            : DateFormat('dd.MM.yyyy').format(measurementDate!),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Кнопка для выбора даты замера
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: Colors.deepPurpleAccent,
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
                  style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
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
                    // Проверка: не раньше рождения
                    if (childBirthDate != null && measurementDate!.isBefore(childBirthDate!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Дата не может быть раньше рождения')),
                      );
                      return;
                    }
                    // И не в будущем
                    if (measurementDate!.isAfter(DateTime.now())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Дата не может быть в будущем')),
                      );
                      return;
                    }
                    // Создаём новую запись
                    final newMeasurement = UserMeasurement(
                      date: measurementDate!,
                      value: val,
                      type: selectedMetric,
                    );
                    setState(() {
                      userMeasurements.add(newMeasurement);
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Удаление записи
  void _deleteMeasurement(int index) {
    setState(() {
      userMeasurements.removeAt(index);
    });
  }

  /// Данные ВОЗ для текущей метрики
  List<WhoDataPoint> get whoData {
    return (selectedMetric == MetricType.height) ? whoHeightBoys : whoWeightBoys;
  }

  /// Точки ВОЗ (50-й перцентиль)
  List<FlSpot> get whoSpots {
    return whoData.map((dp) => FlSpot(dp.month, dp.p50)).toList();
  }

  /// Точки пользовательских замеров
  List<FlSpot> get userSpots {
    if (childBirthDate == null) return [];
    final baseDate = childBirthDate!;
    final filtered = userMeasurements.where((m) => m.type == selectedMetric).toList();
    return filtered.map((m) {
      final diffInDays = m.date.difference(baseDate).inDays;
      final months = diffInDays / 30.0;
      return FlSpot(months, m.value);
    }).toList();
  }

  /// Подпись оси X
  Widget _buildBottomTitle(double value, TitleMeta meta) {
    if (value >= 0 && value <= 36 && value % 6 == 0) {
      return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
    }
    return const SizedBox();
  }

  /// Подпись оси Y
  Widget _buildLeftTitle(double value, TitleMeta meta) {
    if (selectedMetric == MetricType.height) {
      if (value % 10 == 0 && value >= 0 && value <= 120) {
        return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
      }
    } else {
      if (value % 2 == 0 && value >= 0 && value <= 20) {
        return Text(value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
      }
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    // Максимальное значение по Y
    final maxY = (selectedMetric == MetricType.height) ? 120.0 : 20.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Рост / Вес ребёнка'),
        backgroundColor: Colors.teal[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Карточка "Дата рождения"
            if (childBirthDate != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.cake, color: Colors.deepOrange),
                  title: Text(
                    'Дата рождения: ${DateFormat('dd.MM.yyyy').format(childBirthDate!)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Нажмите, чтобы изменить'),
                  onTap: _showBirthDateDialog,
                ),
              )
            else
            // Если дата рождения не выбрана
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: const Icon(Icons.cake_outlined),
                  title: const Text('Укажите дату рождения'),
                  subtitle: const Text('Нажмите, чтобы выбрать'),
                  onTap: _showBirthDateDialog,
                ),
              ),

            const SizedBox(height: 16),

            // График (если дата рождения задана)
            if (childBirthDate != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(8),
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: 36,
                      minY: 0,
                      maxY: maxY,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          axisNameWidget: Text(
                            (selectedMetric == MetricType.height) ? '↑ Рост (см)' : '↑ Вес (кг)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          axisNameSize: 18,
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: _buildLeftTitle,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          axisNameWidget: const Text(
                            'Возраст (мес)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          axisNameSize: 18,
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
                          color: Colors.green,
                          barWidth: 3,
                        ),
                        // Линия пользовательских данных
                        LineChartBarData(
                          spots: userSpots,
                          isCurved: false,
                          color: Colors.blueAccent,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Переключатель метрики + кнопка "Добавить"
            if (childBirthDate != null) ...[
              Row(
                children: [
                  const Text('Метрика:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  DropdownButton<MetricType>(
                    value: selectedMetric,
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
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  backgroundColor: Colors.teal[700],
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: _showAddMeasurementDialog,
                child: Text(
                  (selectedMetric == MetricType.height)
                      ? 'Добавить показатель роста'
                      : 'Добавить показатель веса',
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Таблица с данными
            if (childBirthDate != null && userMeasurements.isNotEmpty)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Введённые данные:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DataTable(
                        columnSpacing: 8,
                        headingRowColor: MaterialStateProperty.all(Colors.teal.shade50),
                        columns: const [
                          DataColumn(label: Text('№', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Мес', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Знач', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('Дата', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          DataColumn(label: Text('X', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                        rows: List.generate(userMeasurements.length, (index) {
                          final m = userMeasurements[index];
                          final baseDate = childBirthDate!;
                          final diffInDays = m.date.difference(baseDate).inDays;
                          final months = (diffInDays / 30).floor();
                          final dateStr = DateFormat('dd.MM.yy').format(m.date);
                          final valueStr = (m.type == MetricType.height)
                              ? '${m.value} см'
                              : '${m.value} кг';
                          return DataRow(cells: [
                            DataCell(Text('${index + 1}', style: const TextStyle(fontSize: 12))),
                            DataCell(Text('$months', style: const TextStyle(fontSize: 12))),
                            DataCell(Text(valueStr, style: const TextStyle(fontSize: 12))),
                            DataCell(Text(dateStr, style: const TextStyle(fontSize: 12))),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                onPressed: () => _deleteMeasurement(index),
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

///
/// Диалог с CupertinoDatePicker (год/месяц/день) по центру экрана
/// + кнопки "Отмена" / "Сохранить".
///
/// Чтобы использовать:
/// - передать title (String)
/// - передать initialDate, minDate, maxDate
/// - передать onDateSaved (функция, которая получит выбранную дату)
///
void showCenteredCupertinoDatePicker({
  required BuildContext context,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          height: 380,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              Expanded(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(shape: const StadiumBorder()),
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

///
/// Три спиннера (Dropdown) для выбора даты
/// (если захотите вместо CupertinoDatePicker).
///
class _TripleSpinnerDatePicker extends StatefulWidget {
  final int minYear;
  final int maxYear;
  final void Function(DateTime) onDateSelected;

  const _TripleSpinnerDatePicker({
    Key? key,
    required this.minYear,
    required this.maxYear,
    required this.onDateSelected,
  }) : super(key: key);

  @override
  State<_TripleSpinnerDatePicker> createState() => _TripleSpinnerDatePickerState();
}

class _TripleSpinnerDatePickerState extends State<_TripleSpinnerDatePicker> {
  int selectedDay = 1;
  int selectedMonth = 1;
  late int selectedYear;

  @override
  void initState() {
    super.initState();
    selectedYear = widget.minYear;
  }

  @override
  Widget build(BuildContext context) {
    final days = List.generate(31, (i) => i + 1);
    final months = List.generate(12, (i) => i + 1);
    final years = List.generate((widget.maxYear - widget.minYear) + 1,
            (i) => widget.minYear + i);

    void updateDate() {
      try {
        final date = DateTime(selectedYear, selectedMonth, selectedDay);
        if (date.day == selectedDay && date.month == selectedMonth) {
          widget.onDateSelected(date);
        }
      } catch (_) {}
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: DropdownButton<int>(
            isExpanded: true,
            value: selectedDay,
            items: days.map((d) {
              return DropdownMenuItem<int>(
                value: d,
                child: Text('$d'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedDay = val;
                });
                updateDate();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<int>(
            isExpanded: true,
            value: selectedMonth,
            items: months.map((m) {
              return DropdownMenuItem<int>(
                value: m,
                child: Text('$m'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedMonth = val;
                });
                updateDate();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButton<int>(
            isExpanded: true,
            value: selectedYear,
            items: years.map((y) {
              return DropdownMenuItem<int>(
                value: y,
                child: Text('$y'),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  selectedYear = val;
                });
                updateDate();
              }
            },
          ),
        ),
      ],
    );
  }
}
