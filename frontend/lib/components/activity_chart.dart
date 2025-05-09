import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/theme_notifier.dart';
import '../services/daily_summary_service.dart';

class ActivityChart extends StatefulWidget {
  const ActivityChart({super.key});

  @override
  State<ActivityChart> createState() => _ActivityChartState();
}

class _ActivityChartState extends State<ActivityChart> {
  List<ChartData> chartData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    final service = DailySummaryService();
    final result = await service.getDailySummaryToday();

    if (result.containsKey('data') && result['data']['dailySummary'] != null) {
      final summary = result['data']['dailySummary'];

      setState(() {
        chartData = [
          // Chuyển đổi thành double an toàn bằng cách xử lý từng trường hợp riêng
          ChartData(AppLocalizations.of(context)!.idle,
              _safeToDouble(summary['total_idle_time']), Colors.red),
          ChartData(
              AppLocalizations.of(context)!.stepping_stairs,
              _safeToDouble(summary['total_stepping_stair_time']),
              Colors.yellow),
          ChartData(AppLocalizations.of(context)!.running,
              _safeToDouble(summary['total_running_time']), Colors.blue),
          ChartData(AppLocalizations.of(context)!.walking,
              _safeToDouble(summary['total_walking_time']), Colors.green),
        ];
        isLoading = false;
      });
    } else {
      // No data or error → show all 0s
      setState(() {
        chartData = [
          ChartData(AppLocalizations.of(context)!.idle, 0.0, Colors.red),
          ChartData(AppLocalizations.of(context)!.stepping_stairs, 0.0,
              Colors.yellow),
          ChartData(AppLocalizations.of(context)!.running, 0.0, Colors.blue),
          ChartData(AppLocalizations.of(context)!.walking, 0.0, Colors.green),
        ];
        isLoading = false;
      });
    }
  }

  // Hàm tiện ích để chuyển đổi an toàn sang double
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    const double maximumValue = 8;

    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 231, 229, 229),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 180,
                        height: 180,
                        child: SfCircularChart(
                          series: <RadialBarSeries<ChartData, String>>[
                            RadialBarSeries<ChartData, String>(
                              dataSource: chartData,
                              maximumValue: maximumValue,
                              radius: '90%',
                              innerRadius: '20%',
                              cornerStyle: CornerStyle.bothCurve,
                              trackColor: Colors.grey.withOpacity(0.2),
                              pointColorMapper: (ChartData data, _) =>
                                  data.color.withOpacity(data.y / maximumValue),
                              xValueMapper: (ChartData data, _) => data.label,
                              yValueMapper: (ChartData data, _) => data.y,
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: chartData.map((data) {
                          return LegendItem(
                            color: data.color,
                            text:
                                '${data.label}: ${data.y.toStringAsFixed(2)} ${AppLocalizations.of(context)!.hours}',
                          );
                        }).toList(),
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
  ChartData(this.label, this.y, this.color);
  final String label;
  final double y;
  final Color color;
}

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
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final parts = text.split(': ');
    final title = parts[0];
    final value = parts.length > 1 ? parts[1] : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isDarkMode
                          ? Colors.white
                          : Colors.black)),
              Text(value,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
