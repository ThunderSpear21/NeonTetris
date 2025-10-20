import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/game_result_model.dart';
import 'package:neon_tetris_frontend/models/live_standing_model.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';
import 'package:neon_tetris_frontend/widgets/tetris_board.dart';

class OpponentState extends Equatable {
  final User user;
  final int score;
  final bool isDefeated;
  const OpponentState({required this.user, this.score = 0, this.isDefeated = false});

  OpponentState copyWith({int? score, bool? isDefeated}) {
    return OpponentState(
      user: user,
      score: score ?? this.score,
      isDefeated: isDefeated ?? this.isDefeated,
    );
  }

  @override
  List<Object> get props => [user, score, isDefeated];
}

abstract class GameState extends Equatable {
  const GameState();
  @override
  List<Object?> get props => [];
}

class GameInitial extends GameState {}

class GameLoading extends GameState {}

class GameReady extends GameState {
  final List<List<int>> gameBoard;
  final Piece? currentPiece;
  final Position? piecePosition;
  final List<String> pieceQueue;
  final int score;
  final int linesCleared;
  final int tickRate;
  final int pendingGarbage;
  final Map<String, OpponentState> opponents;
  final bool isPlayerDefeated;
  final List<LiveStanding>? standings;

  const GameReady({
    required this.gameBoard,
    this.currentPiece,
    this.piecePosition,
    required this.pieceQueue,
    this.score = 0,
    this.linesCleared = 0,
    this.tickRate = 10000,
    this.pendingGarbage = 0,
    required this.opponents,
    this.isPlayerDefeated = false,
    this.standings
  });

  GameReady copyWith({
    List<List<int>>? gameBoard,
    Piece? currentPiece,
    Position? piecePosition,
    List<String>? pieceQueue,
    int? score,
    int? linesCleared,
    int? tickRate,
    int? pendingGarbage,
    Map<String, OpponentState>? opponents,
    bool? isPlayerDefeated,
    List<LiveStanding>? standings
  }) {
    return GameReady(
      gameBoard: gameBoard ?? this.gameBoard,
      currentPiece: currentPiece ?? this.currentPiece,
      piecePosition: piecePosition ?? this.piecePosition,
      pieceQueue: pieceQueue ?? this.pieceQueue,
      score: score ?? this.score,
      linesCleared: linesCleared ?? this.linesCleared,
      tickRate: tickRate ?? this.tickRate,
      pendingGarbage: pendingGarbage ?? this.pendingGarbage,
      opponents: opponents ?? this.opponents,
      isPlayerDefeated: isPlayerDefeated ?? this.isPlayerDefeated,
      standings: standings ?? this.standings
    );
  }

  @override
  List<Object?> get props => [
        gameBoard,
        currentPiece,
        piecePosition,
        pieceQueue,
        score,
        linesCleared,
        tickRate,
        pendingGarbage,
        opponents,
        isPlayerDefeated,
        standings
      ];
}

class GameError extends GameState {
  final String message;
  const GameError(this.message);
}

class GameFinished extends GameState {
  final List<GameResult> results;
  const GameFinished(this.results);

  @override
  List<Object> get props => [results];
}