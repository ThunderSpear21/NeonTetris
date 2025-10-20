import 'package:equatable/equatable.dart';

class LeaderboardEntry extends Equatable {
  final String username;
  final String? avatarUrl;
  final int gamesWon;
  final int gamesPlayed;
  final int highestScore;

  const LeaderboardEntry({
    required this.username,
    this.avatarUrl,
    required this.gamesWon,
    required this.gamesPlayed,
    required this.highestScore,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      username: json['username'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      gamesWon: json['gamesWon'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      highestScore: json['highestScore'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [username, avatarUrl, gamesWon, gamesPlayed, highestScore];
}