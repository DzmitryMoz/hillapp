// lib/widgets/health_panel.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class HealthPanel extends StatelessWidget {
  final VoidCallback onTap;

  const HealthPanel({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Заглушка данных
    final bpData = [
      const FlSpot(0, 120),
      const FlSpot(1, 118),
      const FlSpot(2, 121),
      const FlSpot(3, 119),
      const FlSpot(4, 120),
    ];

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Текущее АД: 120/80'),
                  SizedBox(height: 4),
                  Text('Текущий пульс: 75 уд/мин'),
                ],
              ),
            ),
            SizedBox(
              width: 100,
              height: 60,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: bpData,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.blue,
                      dotData: FlDotData(show: false),
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
