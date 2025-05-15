import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Đảm bảo bạn đã import thư viện intl
import '../models/global_data.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_localization_provider.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Định dạng lại thời gian chỉ lấy giờ và phút và thêm AM/PM
    String formattedTime = '';
    if (GlobalData.currentTimestamp.isNotEmpty) {
      DateTime timestamp = DateTime.parse(GlobalData.currentTimestamp);
      formattedTime = DateFormat('hh:mm a').format(timestamp); // Định dạng giờ:phút AM/PM
    }

    // Xử lý 'stepping_stair' và viết hoa chữ cái đầu của currentActivity
    String formattedActivity = GlobalData.currentActivity;

    if (formattedActivity == 'stepping_stair') {
      // Nếu currentActivity là 'stepping_stair', đổi thành 'Stepping stair'
      formattedActivity = 'Stepping stair';
    } else if (formattedActivity.isNotEmpty) {
      // Viết hoa chữ cái đầu cho các hành động khác
      formattedActivity = formattedActivity[0].toUpperCase() + formattedActivity.substring(1);
    }

    // Tạo action
    String action = 'Motion detected - $formattedActivity';

    // Tạo mockNotifications với dữ liệu đã định dạng
    List<Map<String, String>> mockNotifications = [
      {'time': formattedTime, 'action': action}
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notifications),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        itemCount: mockNotifications.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(mockNotifications[index]['time']!),
              subtitle: Text(mockNotifications[index]['action']!),
            ),
          );
        },
      ),
    );
  }
}
