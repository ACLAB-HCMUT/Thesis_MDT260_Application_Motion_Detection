import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/activity_chart.dart';
import 'detail_screen.dart';
import '../l10n/app_localizations.dart';
import '../components/active_chart_replay.dart';
import '../services/daily_summary_service.dart';
import '../models/theme_notifier.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String fullName = '';
  final authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await authService.getUserProfile();
    setState(() {
      fullName = profile['user']['full_name'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final service = DailySummaryService();

    Future<Map<String, dynamic>> fetchSummary() async {
      return await service.getDailySummaryToday();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.home),
        backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: themeNotifier.isDarkMode ? Colors.black : Colors.white,
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchSummary(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            );
          }

          final data = snapshot.data;
          final dailySummary = data?['data']?['dailySummary'] ?? {};
          final int stepsToday = (dailySummary['total_steps'] ?? 0).toInt();
          final double caloriesBurned = dailySummary['total_calories'] ?? 0.0;

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 16),
                  child: Text(
                    '${AppLocalizations.of(context)!.hello} ${fullName.isNotEmpty ? fullName : ''}!',
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
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: _infoCard(
                    context,
                    icon: Icons.directions_walk,
                    label:
                        '${AppLocalizations.of(context)!.step_today} $stepsToday ${AppLocalizations.of(context)!.step}',
                    themeNotifier: themeNotifier,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _infoCard(
                    context,
                    icon: Icons.whatshot,
                    label:
                        "${AppLocalizations.of(context)!.calories_burned} ${caloriesBurned.toStringAsFixed(2)} kcal",
                    themeNotifier: themeNotifier,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 250,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const DetailScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ).copyWith(
                      elevation: WidgetStateProperty.all(0),
                      overlayColor: WidgetStateProperty.all(
                          Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.purple],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 200,
                          minHeight: 50,
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(BuildContext context,
      {required IconData icon,
      required String label,
      required ThemeNotifier themeNotifier}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: themeNotifier.isDarkMode
            ? Colors.grey[800]
            : const Color.fromARGB(255, 224, 204, 204),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.green, size: 24),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: themeNotifier.isDarkMode ? Colors.white : Colors.black,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
