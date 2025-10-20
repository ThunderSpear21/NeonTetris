import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:neon_tetris_frontend/constants.dart';
import 'package:neon_tetris_frontend/models/leaderboard_entry_model.dart';
import '../models/user_model.dart';
import 'session_manager.dart';

class UserService {
  static final String baseUrl = BASE_URL;
  static final _baseUrl = '$baseUrl/auth';

  static dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'An unknown error occurred');
    }
  }

  static Future<User> getCurrentUser() async {
    final token = await SessionManager.getAccessToken();
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/get-current-user'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = _handleResponse(res);
      return User.fromJson(data);
    } catch (_) {
      rethrow;
    }
  }

  static Future<User> updateAvatar(
    Uint8List imageBytes,
    String filename,
  ) async {
    final url = Uri.parse('$_baseUrl/update-account');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');

    var request = http.MultipartRequest('PATCH', url)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(
        http.MultipartFile.fromBytes('avatar', imageBytes, filename: filename),
      );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = _handleResponse(response);
      return User.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<LeaderboardEntry>> getLeaderboard() async {
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/get-leaderboard'),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = _handleResponse(res);
      if (data is List) {
        return data.map((entry) => LeaderboardEntry.fromJson(entry)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }
}
