import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/theme_notifier.dart';
import '../services/daily_summary_service.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  // Initialize variables for total values (Steps, Calories)
  int totalSteps = 0;
  double totalCalories = 0.0;
  double totalIdleTime = 0.0;
  double totalWalkingTime = 0.0;
  double totalRunningTime = 0.0;
  double totalSteppingStairTime = 0.0;
  List<ActivityData> filteredData = [];
  bool isLoading = true;

  /// **Fetch Data by Date Range**
  Future<void> fetchDataByDateRange() async {
    setState(() {
      isLoading = true;
      // Đặt lại tất cả chỉ số về 0 ngay khi bắt đầu fetch
      totalSteps = 0;
      totalCalories = 0.0;
      totalIdleTime = 0.0;
      totalWalkingTime = 0.0;
      totalRunningTime = 0.0;
      totalSteppingStairTime = 0.0;
      filteredData = [];
    });

    try {
      final service = DailySummaryService();
      final result = await service.getDailySummaryByDateRange(
        DateFormat('yyyy-MM-dd').format(startDate),
        DateFormat('yyyy-MM-dd').format(endDate),
      );

      if (result.containsKey('data') && result['data']['summary'] != null) {
        final summary = result['data']['summary'];

        if (summary.isEmpty) {
          // Không có dữ liệu -> Các chỉ số vẫn bằng 0 như trên
          setState(() {
            filteredData = [
              ActivityData(AppLocalizations.of(context)!.no_data, 0, 0.0, 0.0,
                  0.0, 0.0, 0.0),
            ];
            isLoading = false;
          });
          return;
        }

        int totalDays = endDate.difference(startDate).inDays + 1;

        setState(() {
          totalSteps = summary['total_steps'] ?? 0;
          totalCalories = _safeConvertToDouble(summary['total_calories']);
          totalIdleTime = _safeConvertToDouble(summary['total_idle_time']);
          totalWalkingTime =
              _safeConvertToDouble(summary['total_walking_time']);
          totalRunningTime =
              _safeConvertToDouble(summary['total_running_time']);
          totalSteppingStairTime =
              _safeConvertToDouble(summary['total_stepping_stair_time']);
        });

        double averageIdleTime = totalIdleTime / totalDays;
        double averageWalkingTime = totalWalkingTime / totalDays;
        double averageRunningTime = totalRunningTime / totalDays;
        double averageSteppingStairTime = totalSteppingStairTime / totalDays;

        setState(() {
          filteredData = [
            ActivityData(
              AppLocalizations.of(context)!.average_per_day,
              totalSteps ~/ totalDays,
              totalCalories / totalDays,
              averageIdleTime,
              averageWalkingTime,
              averageSteppingStairTime,
              averageRunningTime,
            )
          ];
          isLoading = false;
        });
      } else {
        // Khi không có 'summary' -> reset giá trị về 0 và hiển thị "Không có dữ liệu"
        setState(() {
          filteredData = [
            ActivityData(AppLocalizations.of(context)!.no_data, 0, 0.0, 0.0,
                0.0, 0.0, 0.0),
          ];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        filteredData = [
          ActivityData(AppLocalizations.of(context)!.no_data, 0, 0.0, 0.0, 0.0,
              0.0, 0.0),
        ];
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchDataByDateRange(); // Call fetch data when screen loads
  }

  /// **Select Date**
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDate : endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 2000)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Kiểm tra xem ngày được chọn có hợp lệ không
      if (!isStart && picked.isBefore(startDate)) {
        // Hiển thị thông báo lỗi nếu endDate trước startDate
        _showTimeOrderErrorDialog(context);
        return;
      }

      setState(() {
        if (isStart) {
          // Nếu ngày bắt đầu mới lớn hơn ngày kết thúc hiện tại
          if (picked.isAfter(endDate)) {
            _showTimeOrderErrorDialog(context);
            return;
          }
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      fetchDataByDateRange(); // Refetch data when date is selected
    }
  }

  // Hiển thị thông báo lỗi khi thời gian không hợp lệ
  void _showTimeOrderErrorDialog(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor:
              themeNotifier.isDarkMode ? Colors.grey[850] : Colors.grey[200],
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.show_error,
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        themeNotifier.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activity_log),
        backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
      ),
      backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// **Select Start and End Date**
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: _datePickerButton(
                            context,
                            AppLocalizations.of(context)!.from,
                            startDate,
                            true),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _datePickerButton(context,
                            AppLocalizations.of(context)!.to, endDate, false),
                      ),
                    ],
                  ),
                ),

                /// **Column Chart**
                Expanded(
                  child: filteredData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.bar_chart_outlined,
                                  color: Colors.white30, size: 48),
                              const SizedBox(height: 16),
                              const Text(
                                  "Không có dữ liệu cho phạm vi ngày đã chọn",
                                  style: TextStyle(color: Colors.white70)),
                              const SizedBox(height: 8),
                              Text(
                                  "${DateFormat('dd/MM/yyyy').format(startDate)} - ${DateFormat('dd/MM/yyyy').format(endDate)}",
                                  style: TextStyle(
                                      color: Colors.white38, fontSize: 12)),
                            ],
                          ),
                        )
                      : SfCartesianChart(
                          backgroundColor: themeNotifier.isDarkMode
                              ? Colors.black
                              : Colors.white,
                          primaryXAxis: CategoryAxis(
                            labelStyle: TextStyle(
                                color: themeNotifier.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                            majorGridLines: const MajorGridLines(width: 0),
                            minorGridLines: const MinorGridLines(width: 0),
                            axisLine:
                                const AxisLine(width: 1, color: Colors.white30),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: TextStyle(
                                color: themeNotifier.isDarkMode
                                    ? Colors.white
                                    : Colors.black),
                            minimum: 0,
                            maximum: 8,
                          ),
                          legend: Legend(
                            isVisible: false,
                          ),
                          tooltipBehavior: TooltipBehavior(enable: true),
                          series: <ChartSeries>[
                            ColumnSeries<ActivityData, String>(
                              name: AppLocalizations.of(context)!.idle,
                              dataSource: filteredData,
                              xValueMapper: (ActivityData data, _) => data.day,
                              yValueMapper: (ActivityData data, _) =>
                                  data.idleTime, // Đúng là idleTime
                              color: Colors.red,
                            ),
                            ColumnSeries<ActivityData, String>(
                              name: AppLocalizations.of(context)!.walking,
                              dataSource: filteredData,
                              xValueMapper: (ActivityData data, _) => data.day,
                              yValueMapper: (ActivityData data, _) =>
                                  data.walkingTime, // Đúng là walkingTime
                              color: Colors.green,
                            ),
                            ColumnSeries<ActivityData, String>(
                              name:
                                  AppLocalizations.of(context)!.stepping_stairs,
                              dataSource: filteredData,
                              xValueMapper: (ActivityData data, _) => data.day,
                              yValueMapper: (ActivityData data, _) => data
                                  .steppingStairTime, // Đúng là steppingStairTime
                              color: Colors.yellow,
                            ),
                            ColumnSeries<ActivityData, String>(
                              name: AppLocalizations.of(context)!.running,
                              dataSource: filteredData,
                              xValueMapper: (ActivityData data, _) => data.day,
                              yValueMapper: (ActivityData data, _) =>
                                  data.runningTime, // Đúng là runningTime
                              color: Colors.blue,
                            ),
                          ],
                        ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: [
                      _activityLabel(
                          AppLocalizations.of(context)!.idle, Colors.red),
                      _activityLabel(
                          AppLocalizations.of(context)!.walking, Colors.green),
                      _activityLabel(
                          AppLocalizations.of(context)!.stepping_stairs,
                          Colors.yellow),
                      _activityLabel(
                          AppLocalizations.of(context)!.running, Colors.blue),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode
                          ? Colors.grey[900]
                          : const Color.fromARGB(255, 224, 204, 204),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statisticRow(AppLocalizations.of(context)!.total_steps,
                            "$totalSteps ${AppLocalizations.of(context)!.step}"),
                        _statisticRow(AppLocalizations.of(context)!.calo_burned,
                            "${totalCalories.toStringAsFixed(1)} kcal"),
                        _statisticRow(
                            AppLocalizations.of(context)!.total_idle_time,
                            "${totalIdleTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}"),
                        _statisticRow(
                            AppLocalizations.of(context)!.total_walking_time,
                            "${totalWalkingTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}"),
                        _statisticRow(
                            AppLocalizations.of(context)!.total_running_time,
                            "${totalRunningTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}"),
                        _statisticRow(
                            AppLocalizations.of(context)!
                                .total_stepping_stair_time,
                            "${totalSteppingStairTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  /// **Date Picker Button**
  Widget _datePickerButton(
      BuildContext context, String label, DateTime date, bool isStart) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: themeNotifier.isDarkMode
              ? Colors.grey[900]
              : const Color.fromARGB(255, 224, 204, 204),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                size: 14),
            const SizedBox(width: 5),
            Text("$label: ${DateFormat("dd/MM/yyyy").format(date)}",
                style: TextStyle(
                    color:
                        themeNotifier.isDarkMode ? Colors.white : Colors.black,
                    fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// **Display Statistic Row**
  Widget _statisticRow(String label, String value) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// **Convert safely to double**
  double _safeConvertToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  /// **Activity Labels (2 per row)**
  Widget _activityLabel(String name, Color color) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: themeNotifier.isDarkMode
            ? Colors.grey[900]
            : const Color.fromARGB(255, 224, 204, 204),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 11),
          const SizedBox(width: 8),
          Text(name,
              style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

/// **Activity Data**
class ActivityData {
  ActivityData(this.day, this.steps, this.calories, this.idleTime,
      this.walkingTime, this.steppingStairTime, this.runningTime);

  final String day;
  final int steps;
  final double calories;
  final double idleTime; // Thời gian đứng yên
  final double walkingTime; // Thời gian đi bộ
  final double steppingStairTime; // Thời gian leo cầu thang
  final double runningTime; // Thời gian chạy
}
