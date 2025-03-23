import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ActivityChartReplay extends StatelessWidget {
  final List<Map<String, dynamic>> data = [
    {'time': '08:00', 'activity': 'Idle'},
    {'time': '08:01', 'activity': 'Walking'},
    {'time': '08:03', 'activity': 'Running'},
    {'time': '08:05', 'activity': 'Going Up Stairs'},
    {'time': '08:08', 'activity': 'Idle'},
    {'time': '08:10', 'activity': 'Walking'},
    {'time': '08:12', 'activity': 'Running'},
  ];

  final Map<String, double> activityMapping = {
    'Idle': 0,
    'Walking': 1,
    'Running': 2,
    'Going Up Stairs': 3,
  };

  final Map<String, IconData> activityIcons = {
    'Idle': Icons.self_improvement,
    'Walking': Icons.directions_walk,
    'Running': Icons.directions_run,
    'Going Up Stairs': Icons.stairs,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text("Activity Chart Replay")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              drawHorizontalLine: true,
              horizontalInterval: 0.5,
              verticalInterval: 0.5,
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (activityMapping.values.contains(value)) {
                      return Icon(
                        activityIcons[activityMapping.keys.firstWhere(
                            (key) => activityMapping[key] == value)],
                        size: 24,
                      );
                    }
                    return SizedBox.shrink();
                  },
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index < 0 || index >= data.length) {
                      return SizedBox.shrink();
                    }
                    return Transform.rotate(
                      angle: -0.5,
                      child: Text(data[index]['time']),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data
                    .asMap()
                    .entries
                    .expand((entry) => [
                          FlSpot(entry.key.toDouble(),
                              activityMapping[entry.value['activity']]!),
                          FlSpot(entry.key.toDouble() + 1,
                              activityMapping[entry.value['activity']]!),
                        ])
                    .toList(),
                isCurved: false,
                barWidth: 3,
                color: Colors.blue,
                dotData: FlDotData(show: false),
                belowBarData: BarAreaData(show: false),
                preventCurveOverShooting: true,
                isStrokeCapRound: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
