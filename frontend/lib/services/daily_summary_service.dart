// daily_summary_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart'; // Import this package for date formatting

class DailySummaryService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? "default_url";
  static final String _dailySummaryEndpoint = "/v1/daily-summary";  // Base endpoint for daily summary

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Lấy token từ FlutterSecureStorage
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      print("Error fetching token: $e");
      return null;
    }
  }

  // Phương thức lấy daily summary cho ngày hiện tại
  Future<Map<String, dynamic>> getDailySummaryToday() async {
    String? _token = await getToken();  // Lấy token từ FlutterSecureStorage

    if (_token == null) {
      return {"error": "User is not authenticated"};
    }

    // Get today's date in the format YYYY-MM-DD
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl$_dailySummaryEndpoint/$today"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',  // Gửi token trong header
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // Parse response body
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? "Error fetching daily summary";
        return {"error": errorMessage};
      }
    } catch (e) {
      print("Error fetching daily summary: $e");
      return {"error": "An error occurred"};
    }
  }


  // Phương thức lấy daily summary theo ngày bắt đầu và ngày kết thúc
  Future<Map<String, dynamic>> getDailySummaryByDateRange(String startDate, String endDate) async {
    String? _token = await getToken();  // Lấy token từ FlutterSecureStorage

    if (_token == null) {
      return {"error": "User is not authenticated"};
    }

    try {
      final uri = Uri.parse("$_baseUrl$_dailySummaryEndpoint?startDate=$startDate&endDate=$endDate");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',  // Gửi token trong header
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);  // Parse response body
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? "Error fetching daily summary";
        return {"error": errorMessage};
      }
    } catch (e) {
      print("Error fetching daily summary: $e");
      return {"error": "An error occurred"};
    }
  }
}
