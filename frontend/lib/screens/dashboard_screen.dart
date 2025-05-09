import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/activity_chart.dart';
import 'detail_screen.dart';
import '../l10n/app_localizations.dart';
import '../components/active_chart_replay.dart';
import '../services/daily_summary_service.dart';
import '../models/theme_notifier.dart'; // Import API service

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    // Fetch data from API for steps and calories
    final service = DailySummaryService();
    Future<Map<String, dynamic>> fetchSummary() async {
      return await service.getDailySummaryToday();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home),
        backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
        automaticallyImplyLeading: false, // false to delete back icon
      ),
      backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchSummary(), // Fetch data when screen loads
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.white)),
            );
          }

          // If data is available, extract steps and calories
          final data = snapshot.data;

          // Check if 'data' and 'dailySummary' are available, if not set default values
          final dailySummary = data?['data']?['dailySummary'] ?? {};

          // Use null-aware operators to set default values if missing data
          final int stepsToday = (dailySummary['total_steps'] ?? 0).toInt();
          final double caloriesBurned = dailySummary['total_calories'] ?? 0.0;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20, left: 16),
                  child: Text(
                    AppLocalizations.of(context)!.hello,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: themeNotifier.isDarkMode
                          ? Colors.white
                          : Colors.black,
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
                // **Step Count Section**
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode
                          ? Colors.grey[800]
                          : const Color.fromARGB(255, 224, 204, 204),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.directions_walk,
                            color: Colors.green, size: 24),
                        Expanded(
                          child: Text(
                            '${AppLocalizations.of(context)!.step_today} $stepsToday ${AppLocalizations.of(context)!.step}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: themeNotifier.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // **Calories Burned Section**
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeNotifier.isDarkMode
                          ? Colors.grey[800]
                          : const Color.fromARGB(255, 224, 204, 204),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.whatshot,
                            color: Colors.green, size: 24),
                        Expanded(
                          child: Text(
                            "${AppLocalizations.of(context)!.calories_burned} ${caloriesBurned.toStringAsFixed(2)} kcal",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: themeNotifier.isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // **Navigate to Detail Screen**
                SizedBox(
                  width: 250, // Giới hạn chiều rộng của nút
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, // Nền trong suốt
                      shadowColor: Colors.transparent, // Loại bỏ bóng đổ
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // Bo góc
                      ),
                    ).copyWith(
                      elevation: WidgetStateProperty.all(
                          0), // Loại bỏ đổ bóng (elevation = 0)
                      overlayColor: WidgetStateProperty.all(Colors.blueAccent
                          .withOpacity(0.2)), // Màu sắc khi nhấn
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(12), // Bo góc của gradient
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 200, // Giới hạn chiều rộng tối thiểu
                          minHeight: 50, // Giới hạn chiều cao tối thiểu
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalizations.of(context)!.all_logs,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: themeNotifier.isDarkMode
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
