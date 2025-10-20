import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:neon_tetris_frontend/models/live_standing_model.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';
import 'package:neon_tetris_frontend/services/session_manager.dart';

class GameService {
  final String _baseUrl = dotenv.env['BASE_URL']!;

  dynamic _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data['data'];
    } else {
      throw Exception(data['message'] ?? 'An unknown error occurred');
    }
  }

  Future<Map<String, dynamic>> getGameState(String roomCode) async {
    final url = Uri.parse('$_baseUrl/game/$roomCode/state');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = _handleResponse(response);
      final opponentsList = (data['opponents'] as List)
          .map((op) => User.fromJson(op))
          .toList();
      final pieceQueue = List<String>.from(data['pieces']);
      return {'pieceQueue': pieceQueue, 'opponents': opponentsList};
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> reportAction({
    required String roomCode,
    required int linesCleared,
    required int scoreGained,
    required int garbageSent,
  }) async {
    final url = Uri.parse('$_baseUrl/game/$roomCode/action');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'linesCleared': linesCleared,
          'scoreGained': scoreGained,
          'garbageSent': garbageSent,
        }),
      );
      final data = _handleResponse(response);
      return List<String>.from(data['nextPieces']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStanding>> playerGameOver(String roomCode) async {
    final url = Uri.parse('$_baseUrl/game/$roomCode/gg');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = _handleResponse(response);
      final standingsList = (data['standings'] as List)
          .map((s) => LiveStanding.fromJson(s))
          .toList();
      return standingsList;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LiveStanding>> getStandings(String roomCode) async {
    final url = Uri.parse('$_baseUrl/game/$roomCode/standings');
    final token = await SessionManager.getAccessToken();
    if (token == null) throw Exception('Token not found');
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = _handleResponse(response);
      final standingsList = (data['standings'] as List)
          .map((s) => LiveStanding.fromJson(s))
          .toList();
      return standingsList;
    } catch (e) {
      rethrow;
    }
  }
}
