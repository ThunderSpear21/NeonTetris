import 'package:equatable/equatable.dart';

class LiveStanding extends Equatable {
  final String username;
  final int score;
  final int placement;
  final bool isAlive;

  const LiveStanding({
    required this.username,
    required this.score,
    required this.placement,
    required this.isAlive,
  });

  factory LiveStanding.fromJson(Map<String, dynamic> json) {
    return LiveStanding(
      username: json['username'],
      score: json['score'],
      placement: json['placement'],
      isAlive: json['isAlive'],
    );
  }

  @override
  List<Object> get props => [username, score, placement, isAlive];
}
