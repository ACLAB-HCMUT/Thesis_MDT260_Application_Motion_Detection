import 'package:flutter/material.dart';

class ActivityChartReplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal, // Cho phép cuộn ngang
        child: CustomPaint(
          size: Size(1500, 300), // Cung cấp một chiều rộng lớn hơn để cuộn
          painter: ActionTimelinePainter(),
        ),
      ),
    );
  }
}

class ActionTimelinePainter extends CustomPainter {
  // Dữ liệu mốc thời gian và hành động
  final List<Map<String, dynamic>> data = [
    {'time': '08:00', 'activity': 'Chạy'},
    {'time': '08:02', 'activity': 'Đi bộ'},
    {'time': '08:04', 'activity': 'Đứng yên'},
    {'time': '08:06', 'activity': 'Đi cầu thang'},
    {'time': '08:08', 'activity': 'Chạy'},
    {'time': '08:10', 'activity': 'Đi bộ'},
    {'time': '08:12', 'activity': 'Đứng yên'},
    {'time': '08:14', 'activity': 'Đi cầu thang'},
    // Thêm nhiều mốc thời gian nếu cần thiết
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 8;  // Độ dày của các đoạn thẳng

    final double marginLeft = 50;  // Độ lệch bên trái để tạo không gian cho trục Y
    final double timeStep = (size.width - marginLeft) / 24;  // Độ dài giữa các mốc thời gian

    // Màu sắc cho các hành động
    List<Color> actionColors = [
      Colors.blue, // Chạy
      Colors.green, // Đi bộ
      Colors.red, // Đứng yên
      Colors.yellow, // Đi cầu thang
    ];

    // Vẽ trục X (thời gian)
    Paint axisPaint = Paint()
      ..color = const Color.fromARGB(255, 207, 199, 199)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(marginLeft, size.height - 40), Offset(size.width, size.height - 40), axisPaint);

    // Vẽ trục Y
    canvas.drawLine(Offset(marginLeft, 0), Offset(marginLeft, size.height), axisPaint);

    // Vẽ mốc thời gian trên trục X
    TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Vẽ các mốc thời gian tương ứng với dữ liệu
    for (int i = 0; i < data.length; i++) {
      String time = data[i]['time'];
      textPainter.text = TextSpan(
        text: time,
        style: TextStyle(color: const Color.fromARGB(255, 228, 219, 219), fontSize: 12),
      );
      textPainter.layout();
      double xPosition = timeToX(time, timeStep, marginLeft);
      textPainter.paint(canvas, Offset(xPosition - textPainter.width / 2, size.height - 30));

      // Vẽ biểu tượng hành động với màu sắc tương ứng
      drawActionIcon(canvas, Offset(xPosition, size.height - 80), i, actionColors[i % actionColors.length]);
    }

    // Vẽ các đoạn thẳng cho từng hành động từ dữ liệu
    for (int i = 0; i < data.length; i++) {
      String activity = data[i]['activity'];
      String time = data[i]['time'];

      // Tính toán thời gian dựa trên giá trị mốc thời gian
      double startX = timeToX(time, timeStep, marginLeft);
      double endX = startX + timeStep; // Đoạn thẳng dài 1 đơn vị thời gian (có thể điều chỉnh nếu cần)

      paint.color = actionColors[i % actionColors.length]; // Sử dụng màu sắc cho các hành động
      // Vẽ các đoạn thẳng cho hành động
      canvas.drawLine(Offset(startX, size.height - 40), Offset(endX, size.height - 40), paint);
    }
  }

  // Hàm chuyển đổi thời gian thành giá trị X trên trục
  double timeToX(String time, double timeStep, double marginLeft) {
    final timeParts = time.split(':');
    final int hour = int.parse(timeParts[0]);
    final int minute = int.parse(timeParts[1]);

    int totalMinutes = (hour - 8) * 60 + minute; // Giả sử thời gian bắt đầu từ 08:00
    return marginLeft + (totalMinutes / 2) * timeStep; // Chuyển thời gian thành đơn vị trên trục X
  }

  // Hàm vẽ các biểu tượng hành động (biểu tượng đi bộ, đứng yên, chạy, đi cầu thang)
  void drawActionIcon(Canvas canvas, Offset position, int actionIndex, Color iconColor) {
    IconData iconData;
    switch (actionIndex % 4) { // Chỉ sử dụng index từ 0 đến 3 để đảm bảo không vượt quá số lượng biểu tượng
      case 0:
        iconData = Icons.directions_run;  // Chạy
        break;
      case 1:
        iconData = Icons.directions_walk; // Đi bộ
        break;
      case 2:
        iconData = Icons.accessibility;  // Đứng yên
        break;
      case 3:
        iconData = Icons.stairs;         // Đi cầu thang
        break;
      default:
        iconData = Icons.help;           // Mặc định nếu không có hành động
    }

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          fontSize: 30,
          color: iconColor, // Sử dụng màu sắc tương ứng với hành động
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
