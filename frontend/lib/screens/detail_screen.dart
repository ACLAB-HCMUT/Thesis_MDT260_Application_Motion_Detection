import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  DateTime startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime endDate = DateTime.now();

  /// **Dữ liệu mẫu**
  final List<ActivityData> allData = [
    ActivityData("Ngày 1", 5000, 200, 5, 6, 3, 8),
    ActivityData("Ngày 2", 6000, 250, 6, 5, 4, 7),
    ActivityData("Ngày 3", 7000, 300, 7, 8, 5, 6),
    ActivityData("Ngày 4", 5500, 225, 4, 7, 6, 9),
    ActivityData("Ngày 5", 6500, 275, 6, 9, 4, 10),
    ActivityData("Ngày 6", 7200, 320, 5, 10, 3, 12),
    ActivityData("Ngày 7", 8000, 350, 7, 8, 6, 11),
  ];

  /// **Lọc dữ liệu theo khoảng ngày**
  List<ActivityData> getFilteredData() {
    if (startDate.isAfter(endDate)) {
      DateTime temp = startDate;
      startDate = endDate;
      endDate = temp;
    }

    int startIndex = (startDate.difference(DateTime.now()).inDays).abs();
    int endIndex = (endDate.difference(DateTime.now()).inDays).abs();

    startIndex = startIndex.clamp(0, allData.length - 1);
    endIndex = endIndex.clamp(startIndex, allData.length - 1);

    return allData.sublist(startIndex, endIndex + 1);
  }

  /// **Chọn ngày**
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    DateTime initialDate = isStart ? startDate : endDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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
    }
  }

  int getTotalSteps() {
    return getFilteredData().fold(0, (sum, data) => sum + data.steps);
  }

  double getTotalCalories() {
    return getFilteredData().fold(0, (sum, data) => sum + data.calories);
  }

  @override
  Widget build(BuildContext context) {
    List<ActivityData> filteredData = getFilteredData();
    int totalSteps = getTotalSteps();
    double totalCalories = getTotalCalories();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nhật ký hoạt động"),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          /// **Chọn ngày bắt đầu và kết thúc**
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _datePickerButton(context, "Từ", startDate, true),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _datePickerButton(context, "Đến", endDate, false),
                ),
              ],
            ),
          ),

          /// **Biểu đồ cột**
          Expanded(
            child: SfCartesianChart(
              backgroundColor: Colors.black,
              primaryXAxis: CategoryAxis(
                labelStyle: const TextStyle(
                    color: Colors.transparent), // Ẩn chữ dưới trục X
                majorGridLines:
                    const MajorGridLines(width: 0), // Ẩn đường lưới ngang
                minorGridLines: const MinorGridLines(width: 0),
                axisLine: const AxisLine(width: 0), // Ẩn trục
              ),
              primaryYAxis: NumericAxis(
                  labelStyle: const TextStyle(color: Colors.white),
                  minimum: 0,
                  maximum: 24),
              series: <ChartSeries>[
                ColumnSeries<ActivityData, String>(
                  name: "Đứng yên",
                  dataSource: filteredData,
                  xValueMapper: (ActivityData data, _) => data.day,
                  yValueMapper: (ActivityData data, _) => data.standing,
                  color: Colors.red,
                ),
                ColumnSeries<ActivityData, String>(
                  name: "Đi bộ",
                  dataSource: filteredData,
                  xValueMapper: (ActivityData data, _) => data.day,
                  yValueMapper: (ActivityData data, _) => data.walking,
                  color: Colors.green,
                ),
                ColumnSeries<ActivityData, String>(
                  name: "Đi cầu thang",
                  dataSource: filteredData,
                  xValueMapper: (ActivityData data, _) => data.day,
                  yValueMapper: (ActivityData data, _) => data.stairs,
                  color: Colors.orange,
                ),
                ColumnSeries<ActivityData, String>(
                  name: "Chạy bộ",
                  dataSource: filteredData,
                  xValueMapper: (ActivityData data, _) => data.day,
                  yValueMapper: (ActivityData data, _) => data.running,
                  color: Colors.blue,
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              children: [
                _activityLabel("Đứng yên", Colors.red),
                _activityLabel("Đi bộ", Colors.green),
                _activityLabel("Đi cầu thang", Colors.orange),
                _activityLabel("Chạy bộ", Colors.blue),
              ],
            ),
          ),

                    Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  _statisticRow("Tổng số bước", "$totalSteps bước"),
                  _statisticRow("Năng lượng tiêu thụ", "$totalCalories kcal"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// **Nút chọn ngày**
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

  /// **Hiển thị dòng thống kê**
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

  /// **Nhãn hoạt động (2 cái một hàng)**
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
          Icon(Icons.circle, color: color, size: 12),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}

/// **Dữ liệu hoạt động**
class ActivityData {
  ActivityData(this.day, this.steps, this.calories, this.standing, this.walking,
      this.stairs, this.running);
  final String day;
  final int steps;
  final double calories;
  final double standing;
  final double walking;
  final double stairs;
  final double running;
}
