import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_localization_provider.dart';
import '../services/daily_summary_service.dart'; // Import the service to call the API

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
      isLoading = true; // Set loading state to true before fetching
    });

    try {
      final service = DailySummaryService();
      final result = await service.getDailySummaryByDateRange(
          DateFormat('yyyy-MM-dd').format(startDate),
          DateFormat('yyyy-MM-dd').format(endDate));

      print("API result structure: ${result.keys}");
      if (result.containsKey('data')) {
        print("Data structure: ${result['data']?.keys}");
      }

      if (result.containsKey('data') &&
          result['data'] != null &&
          result['data']['summary'] != null) {
        final summary = result['data']['summary'];
        print("Summary data: $summary");

        // Calculate total days between start and end date
        int totalDays = endDate.difference(startDate).inDays + 1;

        // Lấy dữ liệu từ summary và cập nhật các biến tổng
        setState(() {
          totalSteps =
              (summary['total_steps'] ?? 0) is int ? summary['total_steps'] : 0;
          totalCalories = (summary['total_calories'] ?? 0.0) is int
              ? (summary['total_calories'] as int).toDouble()
              : (summary['total_calories'] ?? 0.0);
          totalIdleTime = (summary['total_idle_time'] ?? 0.0) is int
              ? (summary['total_idle_time'] as int).toDouble()
              : (summary['total_idle_time'] ?? 0.0);
          totalWalkingTime = (summary['total_walking_time'] ?? 0.0) is int
              ? (summary['total_walking_time'] as int).toDouble()
              : (summary['total_walking_time'] ?? 0.0);
          totalRunningTime = (summary['total_running_time'] ?? 0.0) is int
              ? (summary['total_running_time'] as int).toDouble()
              : (summary['total_running_time'] ?? 0.0);
          totalSteppingStairTime =
              (summary['total_stepping_stair_time'] ?? 0.0) is int
                  ? (summary['total_stepping_stair_time'] as int).toDouble()
                  : (summary['total_stepping_stair_time'] ?? 0.0);
        });

        // Chia các thời gian tổng cho số ngày để có thời gian trung bình mỗi ngày
        double averageIdleTime = totalIdleTime / totalDays;
        double averageWalkingTime = totalWalkingTime / totalDays;
        double averageRunningTime = totalRunningTime / totalDays;
        double averageSteppingStairTime = totalSteppingStairTime / totalDays;

        print("Average Idle Time per Day: $averageIdleTime");
        print("Average Walking Time per Day: $averageWalkingTime");
        print("Average Running Time per Day: $averageRunningTime");
        print("Average Stepping Stair Time per Day: $averageSteppingStairTime");

        // Create new data to display for chart without the need for specific dates
        List<ActivityData> newData = [];
        newData.add(ActivityData(
          'Total',
          totalSteps ~/ totalDays, // Divide total steps by total days
          totalCalories / totalDays, // Divide total calories by total days
          averageIdleTime, // Daily average idle time
          averageWalkingTime, // Daily average walking time
          averageSteppingStairTime, // Daily average stepping stair time
          averageRunningTime, // Daily average running time
        ));

        // Handle case where no data was retrieved (use default zero values)
        if (newData.isEmpty) {
          newData = [
            ActivityData('No Data', 0, 0.0, 0.0, 0.0, 0.0, 0.0),
          ];
        }

        setState(() {
          filteredData = newData;
          isLoading = false;
        });
      } else {
        print("No valid data returned from API");
        setState(() {
          filteredData = [
            ActivityData(AppLocalizations.of(context)!.no_data, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
          ];
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        filteredData = [
          ActivityData(AppLocalizations.of(context)!.no_data, 0, 0.0, 0.0, 0.0, 0.0, 0.0),
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
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
      fetchDataByDateRange(); // Refetch data when date is selected
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.activity_log),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
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
                        child:
                            _datePickerButton(context, AppLocalizations.of(context)!.from, startDate, true),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _datePickerButton(context, AppLocalizations.of(context)!.to, endDate, false),
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
                          backgroundColor: Colors.black,
                          primaryXAxis: CategoryAxis(
                            labelStyle: const TextStyle(color: Colors.white),
                            majorGridLines: const MajorGridLines(width: 0),
                            minorGridLines: const MinorGridLines(width: 0),
                            axisLine:
                                const AxisLine(width: 1, color: Colors.white30),
                          ),
                          primaryYAxis: NumericAxis(
                            labelStyle: const TextStyle(color: Colors.white),
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
                              name: AppLocalizations.of(context)!.stepping_stairs,
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
                      _activityLabel(AppLocalizations.of(context)!.idle, Colors.red),
                      _activityLabel(AppLocalizations.of(context)!.walking, Colors.green),
                      _activityLabel(AppLocalizations.of(context)!.stepping_stairs, Colors.yellow),
                      _activityLabel(AppLocalizations.of(context)!.running, Colors.blue),
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
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _statisticRow(AppLocalizations.of(context)!.total_steps, "$totalSteps ${AppLocalizations.of(context)!.step}"),
                        _statisticRow(AppLocalizations.of(context)!.calo_burned,
                            "${totalCalories.toStringAsFixed(1)} kcal"),
                        _statisticRow(AppLocalizations.of(context)!.total_idle_time,
                            "${totalIdleTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}"),
                        _statisticRow(AppLocalizations.of(context)!.total_walking_time,
                            "${totalWalkingTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}"),
                        _statisticRow(AppLocalizations.of(context)!.total_running_time,
                            "${totalRunningTime.toStringAsFixed(1)} ${AppLocalizations.of(context)!.hours}"),
                        _statisticRow(AppLocalizations.of(context)!.total_stepping_stair_time,
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
    return GestureDetector(
      onTap: () => _selectDate(context, isStart),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.white, size: 14),
            const SizedBox(width: 5),
            Text("$label: ${DateFormat("dd/MM/yyyy").format(date)}",
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  /// **Display Statistic Row**
  Widget _statisticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
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
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, color: color, size: 11),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 12)),
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
