import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ResService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? "http://default-url.com";
  static final String _registerEndpoint = dotenv.env['API_URL_REGISTER'] ?? "/v1/user/register";

  /// Hàm đăng ký tài khoản
  Future<Map<String, dynamic>> registerUser({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl$_registerEndpoint"), // Ghép BASE_URL + ENDPOINT
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "full_name": fullName,
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ?? "Registration failed";
        return {"error": errorMessage};
      }
    } catch (e) {
      return {"error": "An unexpected error occurred: $e"};
    }
  }
}
