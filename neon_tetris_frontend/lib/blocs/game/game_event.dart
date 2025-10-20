import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/game_result_model.dart';

enum MoveDirection { left, right, down }

abstract class GameEvent extends Equatable {
  const GameEvent();
  @override
  List<Object> get props => [];
}

class GameStarted extends GameEvent {}

class PieceMoved extends GameEvent {
  final MoveDirection direction;
  const PieceMoved(this.direction);
}

class PieceRotated extends GameEvent {}

class PieceHardDropped extends GameEvent {}

class GameTicked extends GameEvent {}

class PieceLocked extends GameEvent {}

class TickRateUpdated extends GameEvent {
  final int newTickRate;
  const TickRateUpdated(this.newTickRate);
}

class PlayerScoreUpdated extends GameEvent {
  final String userId;
  final int newScore;
  const PlayerScoreUpdated({required this.userId, required this.newScore});
}

class GarbageReceived extends GameEvent {
  final int lineCount;
  const GarbageReceived(this.lineCount);
}

class PlayerDefeated extends GameEvent {
  final String userId;
  const PlayerDefeated(this.userId);
}

class GameOver extends GameEvent {
  final List<GameResult> results;
  const GameOver(this.results);

  @override
  List<Object> get props => [results];
}


class RefreshStandingsRequested extends GameEvent {}