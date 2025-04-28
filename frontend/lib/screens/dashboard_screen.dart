import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/activity_chart.dart';
import 'detail_screen.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_localization_provider.dart';
import '../components/active_chart_replay.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localeNotifier = Provider.of<AppLocalizationProvider>(context);
    final int stepsToday = 7500; // Số bước chân hôm nay (demo)
    final int stepsGoal = 10000; // Mục tiêu số bước chân
    final double caloriesBurned = 320.5; // Calo tiêu thụ

    return Scaffold(
        appBar: AppBar(
          title: const Text("Home"),
          backgroundColor: Colors.black,
          automaticallyImplyLeading: true, //false to delete icon back
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, left: 16),
                child: Text(
                  "Hello!",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const SizedBox(
                height: 230,
                width: double.infinity,
                child: ActivityChart(),
              ),

              const SizedBox(height: 10),
              SizedBox(
                height: 125,
                width: double.infinity,
                child: ActivityChartReplay(),
              ),

              /// **Hàng chứa số bước chân**
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.directions_walk,
                          color: Colors.green, size: 24),
                      Expanded(
                        child: Text(
                          "Steps Today: $stepsToday steps",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// **Khoảng cách nhỏ**
              const SizedBox(height: 12),

              /// **Box chứa thông tin calo tiêu thụ**
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                 child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.whatshot,
                          color: Colors.green, size: 24),
                      Expanded(
                        child: Text(
                          "Calories Burned Today: $caloriesBurned kcal",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// **Khoảng cách nhỏ**
              const SizedBox(height: 20),

              /// **Nút chuyển sang màn hình chi tiết**
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const DetailScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.transparent, // Để màu nền là gradient
                    shadowColor: Colors.black, // Hiệu ứng bóng đổ
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 14), // Kích thước nút
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Bo góc mềm mại hơn
                    ),
                  ).copyWith(
                    elevation: WidgetStateProperty.all(6), // Độ nổi của nút
                    overlayColor: WidgetStateProperty.all(Colors.blueAccent
                        .withOpacity(0.2)), // Hiệu ứng khi nhấn
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.purple
                        ], // Gradient màu xanh -> tím
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(12), // Bo góc của gradient
                    ),
                    child: Container(
                      constraints: const BoxConstraints(
                          minWidth: 200, minHeight: 50), // Kích thước tối thiểu
                      alignment: Alignment.center,
                      child: const Text(
                        "All Logs",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

