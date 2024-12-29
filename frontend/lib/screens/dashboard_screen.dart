import 'package:flutter/material.dart';
import '../components/activity_chart.dart';
import '../l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
      ),
      body: const Column(
        children: [
          Expanded(
            child: ActivityChart(),
          ),
        ],
      ),
    );
  }
}
