import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/live_detection_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_localization_provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(
            create: (_) => AppLocalizationProvider()), // Add this line
      ],
      child: MotionDetectionApp(),
    ),
  );
}

class MotionDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier =
        Provider.of<AppLocalizationProvider>(context); // Update this line

    return MaterialApp(
      title: 'Motion Detection App',
      theme: themeNotifier.isDarkMode ? ThemeData.dark() : ThemeData.light(),
      locale: localeNotifier.locale,
      supportedLocales:
          AppLocalizations.supportedLocales, // Use AppLocalizations
      localizationsDelegates:
          AppLocalizations.localizationsDelegates, // Use AppLocalizations
      home: MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const LiveDetectionScreen(),
    const SettingsScreen(),
    NotificationsScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard,
                color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.directions_run,
                color: _selectedIndex == 4 ? Colors.blue : Colors.grey),
            label: 'Live Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
                color: _selectedIndex == 1 ? Colors.blue : Colors.grey),
            label: 'Cài đặt',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications,
                color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _selectedIndex == 3 ? Colors.blue : Colors.grey),
            label: 'Hồ sơ',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ThemeNotifier extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
