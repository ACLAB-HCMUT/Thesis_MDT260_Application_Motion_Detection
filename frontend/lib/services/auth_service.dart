import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = "http://localhost:8017/v1/user/login";

  Future<Map<String, dynamic>> login(
      String emailOrUsername, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
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
