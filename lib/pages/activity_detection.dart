import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
class ActivityDetectionPage extends StatefulWidget {
  const ActivityDetectionPage({Key? key}) : super(key: key);

  @override
  _ActivityDetectionPageState createState() => _ActivityDetectionPageState();
}

class _ActivityDetectionPageState extends State<ActivityDetectionPage> {
  String _selectedActivity = 'BREAK';

  final Map<String, String> _animations = {
    'RUNNING': 'assets/animations/running_animation.json',
    'WALKING': 'assets/animations/walking_animation.json',
    'GOING STAIR': 'assets/animations/gostair_animation.json',
    'BREAK': 'assets/animations/break_animation.json',
  };

  final Map<String, Size> _animationSizes = {
    'RUNNING': const Size(200, 200),
    'WALKING': const Size(150, 150),
    'GOING STAIR': const Size(200, 200),
    'BREAK': const Size(200, 200),
  };

  @override
  Widget build(BuildContext context) {
    // Lấy ngày hiện tại
    int currentDayIndex = DateTime.now().weekday - 1;

    // Danh sách các ngày trong tuần
    List<String> daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 58, 156, 201), // Đổi màu nền thành xanh đậm
        title: Wrap(
          spacing: 8.0, // Khoảng cách giữa các ngày
          alignment: WrapAlignment.center,
          children: daysOfWeek.asMap().entries.map((entry) {
            int index = entry.key;
            String day = entry.value;
            bool isToday = index == currentDayIndex;
            return Text(
              day,
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: Colors.amberAccent, // Đổi màu chữ thành vàng nhạt
                fontSize: 16,
              ),
            );
          }).toList(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DropdownButton<String>(
                  value: _selectedActivity,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedActivity = newValue;
                      });
                    }
                  },
                  items: _animations.keys
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    );
                  }).toList(),
                  dropdownColor: Colors.blue[50], // Màu nền của dropdown
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Color(0xFFE1F5FE), // Đổi màu nền của container
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.blue[900]!, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'YOU ARE $_selectedActivity!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue, // Đổi màu chữ
                        ),
                      ),
                      const SizedBox(height: 20),
                      Lottie.asset(
                        _animations[_selectedActivity]!,
                        width: _animationSizes[_selectedActivity]!.width,
                        height: _animationSizes[_selectedActivity]!.height,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
