import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LiveDetectionScreen extends StatelessWidget {
  const LiveDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Detection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live Motion Detection',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.directions_walk, size: 40),
                          SizedBox(height: 8),
                          Text('Walking')
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.directions_run, size: 40),
                          SizedBox(height: 8),
                          Text('Running')
                        ],
                      ),
                      Column(
                        children: [
                          Icon(Icons.stairs, size: 40),
                          SizedBox(height: 8),
                          Text('Climbing Stairs')
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Acceleration Intensity Over Time',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: true),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                getTitlesWidget: (value, meta) {
                                  switch (value.toInt()) {
                                    case 2:
                                      return const Text('2s');
                                    case 5:
                                      return const Text('5s');
                                    case 8:
                                      return const Text('8s');
                                  }
                                  return const Text('');
                                }),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 28,
                                getTitlesWidget: (value, meta) {
                                  return Text('${value.toInt()}');
                                }),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(
                            color: const Color(0xff37434d),
                            width: 1,
                          ),
                        ),
                        minX: 0,
                        maxX: 10,
                        minY: 0,
                        maxY: 10,
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              const FlSpot(0, 3),
                              const FlSpot(2, 5),
                              const FlSpot(4, 7),
                              const FlSpot(6, 8),
                              const FlSpot(8, 6),
                              const FlSpot(10, 9),
                            ],
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 4,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Logic to start live detection
              },
              child: const Text('Start Live'),
            ),
          ],
        ),
      ),
    );
  }
}
