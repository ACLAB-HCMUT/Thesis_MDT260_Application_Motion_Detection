import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final String _baseUrl = dotenv.env['BASE_URL'] ?? "default_url";
  static final String _loginEndpoint =
      dotenv.env['API_URL_LOGIN'] ?? "/v1/user/login";
  static final String _updateUserEndpoint =
      dotenv.env['API_URL_UPDATE_USER'] ?? "/v1/user/profile/edit-profile";
  static final String _getUserProfileEndpoint =
      "/v1/user/profile/"; // Endpoint lấy thông tin người dùng

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Lưu token vào FlutterSecureStorage
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: 'auth_token', value: token);
      print("Token saved successfully!");
    } catch (e) {
      print("Error saving token: $e");
    }
  }

  // Lấy token từ FlutterSecureStorage
  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: 'auth_token');
    } catch (e) {
      print("Error fetching token: $e");
      return null;
    }
  }

  // Phương thức đăng nhập
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
        final data = jsonDecode(response.body);
        String token = data['token']; // Lưu token trong biến
        await saveToken(token); // Lưu token vào FlutterSecureStorage
        return data;
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? "Invalid credentials";
        return {"error": errorMessage};
      }
    } catch (e) {
      print("Error during login: $e");
      return {"error": "An error occurred"};
    }
  }

  // Phương thức cập nhật thông tin người dùng
  Future<Map<String, dynamic>> updateUser(String fullName, String dateOfBirth,
      String gender, double weight, double height) async {
    String? _token = await getToken(); // Lấy token từ FlutterSecureStorage

    if (_token == null) {
      return {"error": "User is not authenticated"};
    }

    try {
      final response = await http.put(
        Uri.parse("$_baseUrl$_updateUserEndpoint"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Gửi token trong header
        },
        body: jsonEncode({
          "full_name": fullName,
          "date_of_birth": dateOfBirth,
          "gender": gender,
          "weight": weight,
          "height": height,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final errorMessage =
            jsonDecode(response.body)['message'] ?? "Error updating user info";
        return {"error": errorMessage};
      }
    } catch (e) {
      return {"error": "An error occurred"};
    }
  }

  // Phương thức lấy thông tin người dùng
  Future<Map<String, dynamic>> getUserProfile() async {
    String? _token = await getToken(); // Lấy token từ FlutterSecureStorage

    if (_token == null) {
      return {"error": "User is not authenticated"};
    }

    try {
      final response = await http.get(
        Uri.parse("$_baseUrl$_getUserProfileEndpoint"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token', // Gửi token trong header
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về thông tin người dùng
      } else {
        final errorMessage = jsonDecode(response.body)['message'] ??
            "Error fetching user profile";
        return {"error": errorMessage};
      }
    } catch (e) {
      return {"error": "An error occurred"};
    }
  }
}
