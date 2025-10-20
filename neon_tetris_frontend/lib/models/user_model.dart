import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String username;
  final String? email;
  final String? avatarUrl;
  final List<String>? friends;
  final GameStats? rankedStats;
  final GameStats? unrankedStats;
  final bool? isOnline;
  final DateTime? lastLogin;

  const User({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    this.friends,
    this.rankedStats,
    this.unrankedStats,
    this.isOnline,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] ?? json; // Handles nested or flat user data
    return User(
      id: userData['_id'] ?? userData['userId'],
      username: userData['username'],
      email: userData['email'],
      avatarUrl: userData['avatarUrl'],
      friends: List<String>.from(userData['friends'] ?? []),
      rankedStats: GameStats.fromJson(userData['rankedStats'] ?? {}),
      unrankedStats: GameStats.fromJson(userData['unrankedStats'] ?? {}),
      isOnline: userData['isOnline'] ?? false,
      lastLogin: userData['lastLogin'] != null
          ? DateTime.parse(userData['lastLogin'])
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        avatarUrl,
        friends,
        rankedStats,
        unrankedStats,
        isOnline,
        lastLogin,
      ];
}

class GameStats extends Equatable {
  final int gamesPlayed;
  final int gamesWon;
  final int linesCleared;
  final int highestScore;

  const GameStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.linesCleared = 0,
    this.highestScore = 0,
  });

  factory GameStats.fromJson(Map<String, dynamic> json) {
    return GameStats(
      gamesPlayed: json['gamesPlayed'] ?? 0,
      gamesWon: json['gamesWon'] ?? 0,
      linesCleared: json['linesCleared'] ?? 0,
      highestScore: json['highestScore'] ?? 0,
    );
  }

  @override
  List<Object> get props => [gamesPlayed, gamesWon, linesCleared, highestScore];
}