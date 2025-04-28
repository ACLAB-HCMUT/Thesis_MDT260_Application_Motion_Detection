import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChartData> chartData = [
      ChartData('Đứng yên:', 5, '100%', Colors.red),
      ChartData('Đi cầu thang', 4, '100%', Colors.yellow),
      ChartData('Chạy bộ', 7, '100%', Colors.blue),
      ChartData('Đi bộ', 8, '100%', Colors.green),
    ];

    const double maximumValue = 24; // Giá trị tối đa

    return Scaffold(
      // backgroundColor: Colors.black, // Nền đen để làm nổi bật biểu đồ
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            height: 200, // Đảm bảo có kích thước xác định
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Biểu đồ
                SizedBox(
                  width: 180, // Điều chỉnh kích thước biểu đồ
                  height: 180,
                  child: SfCircularChart(
                    series: <RadialBarSeries<ChartData, String>>[
                      RadialBarSeries<ChartData, String>(
                        dataSource: chartData,
                        maximumValue: maximumValue,
                        radius: '90%',
                        innerRadius: '20%',
                        cornerStyle: CornerStyle.bothCurve,
                        trackColor: Colors.grey
                            .withOpacity(0.2), // Track mặc định nhạt hơn
                        pointColorMapper: (ChartData data, _) => data.color
                            .withOpacity(data.y /
                                maximumValue), // Độ đậm dựa trên giá trị
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  width: 20, // Khoảng cách giữa biểu đồ và chú thích
                ),

                // Chú thích (legend)
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LegendItem(color: Colors.red, text: 'Idle: 5 hours'),
                    LegendItem(
                        color: Colors.yellow, text: 'Stepping stair: 4 hours'),
                    LegendItem(color: Colors.blue, text: 'Running: 7 hours'),
                    LegendItem(color: Colors.green, text: 'Walking: 8 hours'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.text, this.color);
  final String x;
  final double y;
  final String text;
  final Color color;
}

// Widget để hiển thị chú thích
class LegendItem extends StatelessWidget {
  const LegendItem({
    super.key,
    required this.color,
    required this.text,
  });

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    // Tách tên và số liệu để xuống dòng
    final parts = text.split(': ');
    final title = parts[0]; // Phần tên
    final value = parts.length > 1 ? parts[1] : ''; // Phần số liệu

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Căn chỉnh nội dung trên đầu
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, // Hiển thị phần tiêu đề
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                value, // Hiển thị số liệu xuống dòng
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
