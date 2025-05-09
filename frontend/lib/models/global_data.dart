
class GlobalData {
  static String currentActivity = '';  // Hoạt động mặc định
  static String currentTimestamp = '';  // Thời gian mặc định

  // Cập nhật dữ liệu toàn cục từ activityData
  static void updateFromLastActivity(List<Map<String, dynamic>> activityData) {
    if (activityData.isNotEmpty) {
      // Lấy phần tử cuối cùng
      var lastActivity = activityData.last;
      currentActivity = lastActivity['activity'] ?? 'Stand still';
      currentTimestamp = lastActivity['timestamp'] ?? '';
    }
  }
}
