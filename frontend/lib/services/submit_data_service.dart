import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'auth_service.dart';

class ActivityService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? "default_url";
  static final String _submitEndpoint = dotenv.env['API_URL_SUBMIT_ACTIVITY'] ?? "/v1/activity/submit";

  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> submitActivityData(List<Map<String, dynamic>> activityData) async {
    final String? token = await _authService.getToken();

    if (token == null) {
      return {"error": "User is not authenticated"};
    }

    try {
      final response = await http.post(
        Uri.parse("$_baseUrl$_submitEndpoint"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"data": activityData}),
      );

      print('Submit Response Status: ${response.statusCode}');
      print('Submit Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? "Failed to submit activity data";
        return {"error": errorMessage};
      }
    } catch (e) {
      print("Error submitting activity data: $e");
      return {"error": "An error occurred"};
    }
  }
}
