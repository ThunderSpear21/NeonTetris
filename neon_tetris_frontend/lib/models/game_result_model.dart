import 'package:equatable/equatable.dart';

class GameResult extends Equatable {
  final String username;
  final int score;
  final int placement;

  const GameResult({
    required this.username,
    required this.score,
    required this.placement,
  });

  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      username: json['username'] ?? 'Unknown Player',
      score: json['score'] ?? 0,
      placement: json['placement'] ?? 0,
    );
  }

  @override
  List<Object> get props => [username, score, placement];
}