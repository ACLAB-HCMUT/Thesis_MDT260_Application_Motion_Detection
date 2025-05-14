import 'package:flutter/material.dart';
import 'dart:ui' as dart_ui;
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../services/daily_summary_service.dart';

class ActivityChartReplay extends StatefulWidget {
  const ActivityChartReplay({super.key});

  @override
  _ActivityChartReplayState createState() => _ActivityChartReplayState();
}

class _ActivityChartReplayState extends State<ActivityChartReplay> {
  List<Map<String, dynamic>> _activityData = [];
  bool _isLoading = true;

  // Thêm một biến để theo dõi việc fetch dữ liệu
  bool _isFetchCancelled = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  void dispose() {
    // Đánh dấu fetch bị hủy để ngăn chặn setState sau khi dispose
    _isFetchCancelled = true;
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      // Đợi một khoảng thời gian ngắn để tránh lỗi nếu widget bị dispose ngay lập tức
      await Future.delayed(const Duration(milliseconds: 100));

      // Kiểm tra xem fetch đã bị hủy chưa
      if (_isFetchCancelled) return;

      final data = await DailySummaryService().getDailySummaryToday();

      // print(data); // Log dữ liệu API

      if (_isFetchCancelled) return;

      if (data['error'] == null) {
        final List<dynamic> raw = data['data']?['activities'] ?? [];

        // Sắp xếp dữ liệu theo thời gian
        raw.sort((a, b) => DateTime.parse(a['timestamp'])
            .compareTo(DateTime.parse(b['timestamp'])));

        List<Map<String, dynamic>> parsed = [];
        DateTime?
            lastAddedTimestamp; // Lưu lại timestamp của hoạt động cuối cùng được thêm vào

        // In tất cả dữ liệu trước khi lọc
        // print("All Activities Before Filtering:");
        raw.forEach((item) {
          DateTime timestamp = DateTime.parse(item['timestamp']);
          final time = DateFormat('HH:mm').format(timestamp);
          // print('Activity: ${item['activity']}, Timestamp: $time');
        });

        // Luôn thêm hoạt động đầu tiên
        if (raw.isNotEmpty) {
          var firstItem = raw.first;
          DateTime timestamp = DateTime.parse(firstItem['timestamp']);
          final time = DateFormat('HH:mm').format(timestamp);
          parsed.add({
            'time': time,
            'activity': firstItem['activity'],
          });
          lastAddedTimestamp = timestamp;
          // print(
          //     'Added First Activity: ${firstItem['activity']}, Timestamp: $time');
        }

        // Duyệt qua các hoạt động còn lại
        for (int i = 1; i < raw.length; i++) {
          try {
            var item = raw[i];
            DateTime timestamp = DateTime.parse(item['timestamp']);

            // Chỉ thêm hoạt động nếu nó cách hoạt động cuối cùng được thêm vào ít nhất 2 phút
            if (lastAddedTimestamp != null &&
                timestamp.difference(lastAddedTimestamp).inMinutes >= 2) {
              final time = DateFormat('HH:mm').format(timestamp);
              parsed.add({
                'time': time,
                'activity': item['activity'],
              });
              lastAddedTimestamp = timestamp; // Cập nhật timestamp cuối cùng

              // In ra các hoạt động đã được thêm vào
              // print('Added Activity: ${item['activity']}, Timestamp: $time');
            }
          } catch (e) {
            // Nếu gặp lỗi, bỏ qua dữ liệu không hợp lệ
            print('Error parsing data: $e');
          }
        }

        // In tổng số hoạt động sau khi lọc
        // print('Total activities after filtering: ${parsed.length}');

        // Kiểm tra mounted và không bị hủy trước khi gọi setState
        if (mounted && !_isFetchCancelled) {
          setState(() {
            _activityData = parsed;
            _isLoading = false;
          });
        }
      } else {
        // Xử lý trường hợp có lỗi từ API
        if (mounted && !_isFetchCancelled) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      // Xử lý ngoại lệ
      print('Fetch data error: $e');
      if (mounted && !_isFetchCancelled) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _activityData.isEmpty
              ? Center(
                  child: Text(
                    AppLocalizations.of(context)!.no_data,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: CustomPaint(
                    size:  Size(_activityData.length * 60.0 + 50, 300),
                    painter: ActivityChartPainter(data: _activityData),
                  ),
                ),
    );
  }
}

class ActivityChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  ActivityChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 8;

    final double marginLeft = 50;
    final double totalWidth = size.width - marginLeft;

    // Giới hạn chiều dài tối đa của mỗi đoạn thẳng
    final double fixedBarWidth = 60;

    // Điều chỉnh lại timeStep sao cho không phụ thuộc vào số lượng dữ liệu
    final double timeStep = fixedBarWidth;

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
      textPainter.paint(canvas,
          Offset(size.width / 2 - textPainter.width / 2, size.height / 2));
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

        double xPosition =
            marginLeft + (i * timeStep); // Vị trí x của đoạn thẳng
        textPainter.paint(canvas,
            Offset(xPosition - textPainter.width / 2, size.height - 30));

        // Vẽ hành động (đoạn thẳng) khi có dữ liệu
        paint.color =
            activityColors[activity] ?? Colors.grey; // Màu sắc cho hành động
        canvas.drawLine(
          Offset(xPosition, size.height - 40),
          Offset(xPosition + timeStep,
              size.height - 40), // Vẽ các đoạn thẳng có chiều dài bằng nhau
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
  bool shouldRepaint(covariant ActivityChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
