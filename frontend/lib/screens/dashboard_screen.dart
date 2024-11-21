import 'package:flutter/material.dart';
import '../components/motion_chart.dart';
import '../components/action_indicator.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: const ActionIndicator(status: 'Yên tĩnh'),
          ),
          Expanded(
            child: MotionChart(),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(AppLocalizations.of(context)!.notifications),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Icon(Icons.directions_walk, size: 40),
                    Icon(Icons.directions_run, size: 40),
                    Icon(Icons.stairs, size: 40),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}