import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Measurement {
  final DateTime date;
  final double systolic;
  final double diastolic;
  final double heartRate;

  Measurement({
    required this.date,
    required this.systolic,
    required this.diastolic,
    required this.heartRate,
  });
}

class BloodPressureScreen extends StatefulWidget {
  const BloodPressureScreen({Key? key}) : super(key: key);

  @override
  State<BloodPressureScreen> createState() => _BloodPressureScreenState();
}

class _BloodPressureScreenState extends State<BloodPressureScreen> {
  final List<Measurement> _measurements = [];

  @override
  Widget build(BuildContext context) {
    final sysSpots = <FlSpot>[];
    final diaSpots = <FlSpot>[];
    final hrSpots = <FlSpot>[];

    for (int i = 0; i < _measurements.length; i++) {
      sysSpots.add(FlSpot(i.toDouble(), _measurements[i].systolic));
      diaSpots.add(FlSpot(i.toDouble(), _measurements[i].diastolic));
      hrSpots.add(FlSpot(i.toDouble(), _measurements[i].heartRate));
    }

    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final m in _measurements) {
      if (m.systolic < minY) minY = m.systolic;
      if (m.diastolic < minY) minY = m.diastolic;
      if (m.heartRate < minY) minY = m.heartRate;

      if (m.systolic > maxY) maxY = m.systolic;
      if (m.diastolic > maxY) maxY = m.diastolic;
      if (m.heartRate > maxY) maxY = m.heartRate;
    }

    if (_measurements.isEmpty) {
      minY = 0;
      maxY = 150;
    } else {
      minY = (minY - 10).clamp(0, 9999);
      maxY += 10;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Контроль АД / ЧСС'),
        actions: [
          IconButton(
            onPressed: _deleteAllMeasurements,
            icon: const Icon(Icons.delete),
            tooltip: 'Удалить все данные',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMeasurementDialog,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'График АД и ЧСС',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_measurements.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Text(
                        'Нет данных для отображения',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    AspectRatio(
                      aspectRatio: 1.3,
                      child: LineChart(
                        LineChartData(
                          minY: minY,
                          maxY: maxY,
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  switch (spot.barIndex) {
                                    case 0:
                                      return LineTooltipItem(
                                        'Сист: ${spot.y.toStringAsFixed(0)}',
                                        const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    case 1:
                                      return LineTooltipItem(
                                        'Диаст: ${spot.y.toStringAsFixed(0)}',
                                        const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    default:
                                      return LineTooltipItem(
                                        'ЧСС: ${spot.y.toStringAsFixed(0)}',
                                        const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                  }
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: [
                            _buildLine(sysSpots, Colors.red),
                            _buildLine(diaSpots, Colors.blue),
                            _buildLine(hrSpots, Colors.green),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(
                            show: true,
                            border: Border(
                              left: const BorderSide(color: Colors.black12),
                              bottom: const BorderSide(color: Colors.black12),
                              right: BorderSide(color: Colors.grey.shade200),
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_measurements.isNotEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Мои показатели:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            if (_measurements.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _measurements.length,
                itemBuilder: (context, index) {
                  final m = _measurements[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Дата: ${_formatDate(m.date)}, '
                                'Сист: ${m.systolic.toStringAsFixed(0)}, '
                                'Диаст: ${m.diastolic.toStringAsFixed(0)}, '
                                'ЧСС: ${m.heartRate.toStringAsFixed(0)}',
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteMeasurement(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      barWidth: 3,
      gradient: LinearGradient(colors: [color.withOpacity(0.3), color]),
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, _, __, ___) {
          return LabelDotPainter(
            label: spot.y.toStringAsFixed(0),
            dotColor: color,
          );
        },
      ),
    );
  }

  void _addMeasurementDialog() async {
    double syst = 120;
    double diast = 80;
    double hr = 70;

    final newMeas = await showDialog<Measurement>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Добавить измерение'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Систолическое'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => syst = double.tryParse(val) ?? 120,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'Диастолическое'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => diast = double.tryParse(val) ?? 80,
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: const InputDecoration(labelText: 'ЧСС (уд/мин)'),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => hr = double.tryParse(val) ?? 70,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, null),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                final meas = Measurement(
                  date: DateTime.now(),
                  systolic: syst,
                  diastolic: diast,
                  heartRate: hr,
                );
                Navigator.pop(ctx, meas);
              },
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (newMeas != null) {
      setState(() {
        _measurements.add(newMeas);
      });
    }
  }

  void _deleteMeasurement(int index) {
    setState(() {
      _measurements.removeAt(index);
    });
  }

  void _deleteAllMeasurements() {
    setState(() {
      _measurements.clear();
    });
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d.$m.$y';
  }
}

class LabelDotPainter extends FlDotPainter {
  final String label;
  final Color dotColor;

  LabelDotPainter({required this.label, required this.dotColor});

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offset) {
    final paint = Paint()..color = dotColor;
    canvas.drawCircle(offset, 4, paint);

    const style = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    final tp = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final textOffset = Offset(
      offset.dx - tp.width / 2,
      offset.dy - tp.height - 6,
    );
    tp.paint(canvas, textOffset);
  }

  @override
  Size getSize(FlSpot spot) => const Size(14, 14);

  @override
  Path getPath(Canvas canvas, FlSpot spot, Offset offset) {
    return Path()..addOval(Rect.fromCircle(center: offset, radius: 4));
  }

  @override
  FlDotPainter lerp(FlDotPainter a, FlDotPainter b, double t) {
    if (a is! LabelDotPainter || b is! LabelDotPainter) return this;
    final color = Color.lerp(a.dotColor, b.dotColor, t) ?? dotColor;
    final lbl = t < 0.5 ? a.label : b.label;
    return LabelDotPainter(label: lbl, dotColor: color);
  }

  @override
  Color get mainColor => dotColor;

  @override
  List<Object?> get props => [label, dotColor];
}
