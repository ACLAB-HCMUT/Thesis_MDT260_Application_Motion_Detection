import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MotionChart extends StatelessWidget {
  const MotionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Biểu đồ cột thống kê thời gian các hành động trong tuần hoặc tháng
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 10,
              barGroups: [
                BarChartGroupData(
                  x: 0,
                  barRods: [
                    BarChartRodData(toY: 3, color: Colors.blue),
                  ],
                  showingTooltipIndicators: [0],
                ),
                BarChartGroupData(
                  x: 1,
                  barRods: [
                    BarChartRodData(toY: 5, color: Colors.green),
                  ],
                  showingTooltipIndicators: [0],
                ),
                BarChartGroupData(
                  x: 2,
                  barRods: [
                    BarChartRodData(toY: 7, color: Colors.orange),
                  ],
                  showingTooltipIndicators: [0],
                ),
                BarChartGroupData(
                  x: 3,
                  barRods: [
                    BarChartRodData(toY: 4, color: Colors.red),
                  ],
                  showingTooltipIndicators: [0],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        // Biểu đồ tròn thống kê thời gian hoạt động trong ngày
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  value: 30,
                  title: 'Chạy bộ',
                  color: Colors.blue,
                ),
                PieChartSectionData(
                  value: 20,
                  title: 'Đi bộ',
                  color: Colors.green,
                ),
                PieChartSectionData(
                  value: 25,
                  title: 'Đi cầu thang',
                  color: Colors.red,
                ),
                PieChartSectionData(
                  value: 25,
                  title: 'Đứng yên',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
