import 'package:http/http.dart' as http;
import 'package:neon_tetris_frontend/constants.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';
import 'package:neon_tetris_frontend/services/session_manager.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = BASE_URL;
  static final _baseUrl = '$baseUrl/auth';

  // --- Token Storage ---
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    await SessionManager.saveTokens(accessToken, refreshToken);
  }

  static Future<void> clearTokens() async {
    await SessionManager.clearTokens();
  }

  // --- Token Validation ---
  static Future<bool> isAccessTokenValid() async {
    final token = await SessionManager.getAccessToken();
    if (token == null) return false;
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/get-current-user'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> refreshToken() async {
    final refreshToken = await SessionManager.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        await saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      }
    } catch (_) {}
    return false;
  }

  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200 && responseData['success'] == true) {
      final data = responseData['data'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accessToken', data['accessToken']);
      await prefs.setString('refreshToken', data['refreshToken']);

      await prefs.setString('userId', data['user']['_id']);
      await prefs.setString('userEmail', data['user']['email']);
      await prefs.setString('userUsername', data['user']['username']);
      return User.fromJson(data['user']);
    } else {
      throw Exception(responseData['message'] ?? 'Login failed');
    }
  }

  static Future<void> sendOTP(String email) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    // Check if response is JSON
    final isJson =
        response.headers['content-type']?.contains('application/json') ?? false;

    if (isJson) {
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return;
      } else {
        throw Exception(responseData['message'] ?? 'Something went wrong');
      }
    } else {
      throw Exception("Unexpected server response. Please try again.");
    }
  }

  static Future<void> registerUser(
    String email,
    String username,
    String password,
    String otp,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'username': username,
        'password': password,
        'otp': otp,
      }),
    );

    final contentType = response.headers['content-type'];
    final isJson = contentType?.contains('application/json') ?? false;

    if (isJson) {
      final responseData = jsonDecode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          responseData['success'] == true) {
        return;
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } else {
      throw Exception("Unexpected server response.");
    }
  }

  static Future<bool> logout() async {
    final token = await SessionManager.getAccessToken();

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/logout'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        return true;
      }
      return false;
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      return false;
    }
  }
}
