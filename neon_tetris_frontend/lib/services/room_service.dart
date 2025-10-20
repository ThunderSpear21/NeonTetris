import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neon_tetris_frontend/constants.dart';
import 'package:neon_tetris_frontend/models/room_model.dart';
import 'package:neon_tetris_frontend/services/session_manager.dart';

class RoomService {
  final String _baseUrl = BASE_URL;
  dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'An unknown error occurred');
    }
  }

  Future<void> joinRankedQueue(String queueType) async {
    final url = Uri.parse('$_baseUrl/room/ranked/join/$queueType');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveRankedQueue(String queueType) async {
    final url = Uri.parse('$_baseUrl/room/ranked/leave/$queueType');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Room> createCasualRoom(int roomSize) async {
    final url = Uri.parse('$_baseUrl/room/create/$roomSize');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = _handleResponse(response);
      return Room.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Room> joinCasualRoom(String roomCode) async {
    final url = Uri.parse('$_baseUrl/room/join/$roomCode');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = _handleResponse(response);
      return Room.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveCasualRoom(String roomCode) async {
    final url = Uri.parse('$_baseUrl/room/leave/$roomCode');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      await http.post(url, headers: {'Authorization': 'Bearer $token'});
    } catch (e) {
      rethrow;
    }
  }

  Future<void> startRoom(String roomCode) async {
    final url = Uri.parse('$_baseUrl/room/start/$roomCode');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }
}
