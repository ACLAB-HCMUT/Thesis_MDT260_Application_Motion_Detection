import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? "default_url";
  static final String _loginEndpoint =
      dotenv.env['API_URL_LOGIN'] ?? "/v1/user/login";

  Future<Map<String, dynamic>> login(
      String emailOrUsername, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$_baseUrl$_loginEndpoint"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "emailOrUsername": emailOrUsername,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? "Invalid credentials";
        return {"error": errorMessage};
      }
    } catch (e) {
      return {"error": "An error occurred"};
    }
  }
}
