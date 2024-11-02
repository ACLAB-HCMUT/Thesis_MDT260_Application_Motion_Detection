import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:thesis_application_motion_detection/pages/home_page.dart';
import 'package:thesis_application_motion_detection/pages/activity_detection.dart';
import 'package:thesis_application_motion_detection/pages/setting_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Motion Detection with XIAO SENSE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BLECheckPage(),
    );
  }
}

class BLECheckPage extends StatefulWidget {
  const BLECheckPage({super.key});

  @override
  _BLECheckPageState createState() => _BLECheckPageState();
}

class _BLECheckPageState extends State<BLECheckPage> {
  bool isBLEConnected = false;

  @override
  void initState() {
    super.initState();
    checkBLEConnection();
  }

  void checkBLEConnection() async {
    var connectedDevices = await FlutterBluePlus.connectedDevices;

    setState(() {
      isBLEConnected = true;
      // isBLEConnected = connectedDevices.isNotEmpty; // Kiểm tra nếu có thiết bị kết nối
    });

    if (isBLEConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/background.png',
              width: 250,
              height: 250,
            ),
            const SizedBox(height: 20),
            const Text(
              "Track your Active Lifestyle",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            if (!isBLEConnected)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Color(0xFFA7E8FC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Please connect Bluetooth",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ActivityDetectionPage(),
    SettingPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff37A8A8),
        foregroundColor: Colors.white,
        title: const Text('Hello, USER!'),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Activity Detection',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Setting',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        backgroundColor: const Color(0xffD9D9D9),
        onTap: _onItemTapped,
      ),
    );
  }
}
