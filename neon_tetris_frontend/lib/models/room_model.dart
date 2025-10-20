import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';

class Room extends Equatable {
  final String id;
  final String roomCode;
  final int maxPlayers;
  final List<User> players;
  final String hostId;
  final String status;

  const Room({
    required this.id,
    required this.roomCode,
    required this.maxPlayers,
    required this.players,
    required this.hostId,
    required this.status,
  });

  Room copyWith({
    String? id,
    String? roomCode,
    int? maxPlayers,
    List<User>? players,
    String? hostId,
    String? status,
  }) {
    return Room(
      id: id ?? this.id,
      roomCode: roomCode ?? this.roomCode,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      players: players ?? this.players,
      hostId: hostId ?? this.hostId,
      status: status ?? this.status,
    );
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    var playersList = <User>[];
    if (json['players'] != null && json['players'] is List) {
      playersList = (json['players'] as List)
          .map((playerJson) => User.fromJson(playerJson))
          .toList();
    }

    return Room(
      id: json['_id'],
      roomCode: json['roomCode'],
      maxPlayers: json['maxPlayers'],
      players: playersList,
      hostId: json['createdBy'],
      status: json['status'],
    );
  }

  @override
  List<Object> get props => [id, roomCode, maxPlayers, players, hostId, status];
}