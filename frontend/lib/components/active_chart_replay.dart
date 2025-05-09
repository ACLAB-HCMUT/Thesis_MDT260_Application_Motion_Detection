import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;
import 'package:intl/intl.dart';
import '../services/daily_summary_service.dart'; // Đảm bảo đúng đường dẫn file service của bạn

class ActivityChartReplay extends StatefulWidget {
  const ActivityChartReplay({super.key});

  @override
  _ActivityChartReplayState createState() => _ActivityChartReplayState();
}

class _ActivityChartReplayState extends State<ActivityChartReplay> {
  List<Map<String, dynamic>> _activityData = [];

  @override
  void initState() {
    super.initState();
    fetchActivityData();
  }

  Future<void> fetchActivityData() async {
    final data =
        await DailySummaryService().getDailySummaryToday(); // Gọi API của bạn
    if (data['error'] == null) {
      final List<dynamic> raw = data['data']?['activities'] ?? [];

      // Sắp xếp dữ liệu theo thời gian (nếu cần)
      raw.sort((a, b) => DateTime.parse(a['timestamp'])
          .compareTo(DateTime.parse(b['timestamp'])));

      List<Map<String, dynamic>> parsed = [];
      DateTime? lastTimestamp;

      for (var item in raw) {
        try {
          DateTime timestamp = DateTime.parse(item['timestamp']);

          // Nếu lastTimestamp không phải là null và cách nhau ít nhất 2 phút
          if (lastTimestamp == null ||
              timestamp.difference(lastTimestamp).inMinutes >= 2) {
            final time = DateFormat('HH:mm').format(timestamp);
            parsed.add({
              'time': time,
              'activity': item['activity'],
            });
          }

          // Cập nhật lastTimestamp
          lastTimestamp = timestamp;
        } catch (e) {
          // Nếu gặp lỗi, bỏ qua dữ liệu không hợp lệ
          print('Error parsing data: $e');
        }
      }

      setState(() {
        _activityData = parsed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CustomPaint(
          size: Size(1500, 300),
          painter: ActionTimelinePainter(data: _activityData),
        ),
      ),
    );
  }
}

class ActionTimelinePainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  ActionTimelinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 8;

    final double marginLeft = 50;
    final double timeStep =
        (size.width - marginLeft) / (data.isEmpty ? 1 : data.length); // Phân phối đều

    // Màu sắc của các hành động
    Map<String, Color> activityColors = {
      'idle': Colors.red,
      'running': Colors.blue,
      'stepping_stair': Colors.yellow,
      'walking': Colors.green, // Có thể thêm nhiều hành động nữa
    };

    Paint axisPaint = Paint()
      ..color = const Color.fromARGB(255, 207, 199, 199)
      ..strokeWidth = 2;

    // Vẽ trục X và Y
    canvas.drawLine(Offset(marginLeft, size.height - 40),
        Offset(size.width, size.height - 40), axisPaint); // Trục X
    canvas.drawLine(Offset(marginLeft, 0), Offset(marginLeft, size.height),
        axisPaint); // Trục Y

    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: dart_ui.TextDirection.ltr,
    );

    if (data.isEmpty) {
      // Nếu không có dữ liệu, chỉ vẽ trục
      textPainter.text = const TextSpan(
        text: "No Data",
        style: TextStyle(color: Colors.grey, fontSize: 18),
      );
      textPainter.layout();
      textPainter.paint(
          canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2));
    } else {
      // Vẽ dữ liệu bình thường khi có dữ liệu
      for (int i = 0; i < data.length; i++) {
        String time = data[i]['time'];
        String activity = data[i]['activity'];
        textPainter.text = TextSpan(
          text: time,
          style: const TextStyle(
              color: Color.fromARGB(255, 228, 219, 219), fontSize: 12),
        );
        textPainter.layout();
        double xPosition = marginLeft + (i * timeStep); // Phân phối đều
        textPainter.paint(
            canvas, Offset(xPosition - textPainter.width / 2, size.height - 30));

        // Vẽ hành động (đoạn thẳng) khi có dữ liệu
        paint.color =
            activityColors[activity] ?? Colors.grey; // Màu sắc cho hành động
        canvas.drawLine(
          Offset(xPosition, size.height - 40),
          Offset(xPosition + timeStep, size.height - 40),
          paint,
        );

        // Vẽ icon hành động (optional)
        drawActionIcon(canvas, Offset(xPosition, size.height - 80), activity,
            activityColors[activity] ?? Colors.grey);
      }
    }
  }

  // Hàm để vẽ biểu tượng hành động (như người chạy, leo cầu thang...)
  void drawActionIcon(
      Canvas canvas, Offset position, String activity, Color iconColor) {
    IconData iconData;

    // Lựa chọn biểu tượng dựa trên activity
    switch (activity) {
      case 'running':
        iconData = Icons.directions_run;
        break;
      case 'stepping_stair':
        iconData = Icons.stairs;
        break;
      case 'walking':
        iconData = Icons.directions_walk;
        break;
      case 'idle':
      default:
        iconData = Icons.accessibility;
        break;
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          fontSize: 30,
          color: iconColor,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: dart_ui.TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant ActionTimelinePainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
