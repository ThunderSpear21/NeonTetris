import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/leaderboard_entry_model.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoadSuccess extends LeaderboardState {
  final List<LeaderboardEntry> leaderboard;

  const LeaderboardLoadSuccess(this.leaderboard);

  @override
  List<Object> get props => [leaderboard];
}

class LeaderboardLoadFailure extends LeaderboardState {
  final String error;

  const LeaderboardLoadFailure(this.error);
}