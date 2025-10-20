import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/game/game_event.dart';
import 'package:neon_tetris_frontend/blocs/game/game_state.dart';
import 'package:neon_tetris_frontend/models/game_result_model.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';
import 'package:neon_tetris_frontend/services/game_service.dart';
import 'package:neon_tetris_frontend/services/websocket_service.dart';
import 'package:neon_tetris_frontend/widgets/tetris_board.dart';

const int gameBoardRows = 20;
const int gameBoardCols = 10;

class GameBloc extends Bloc<GameEvent, GameState> {
  final String roomCode;
  final GameService _gameService;
  final WebSocketService _webSocketService;

  StreamSubscription? _webSocketSubscription;
  Timer? _timer;

  GameBloc({
    required this.roomCode,
    required GameService gameService,
    required WebSocketService webSocketService,
  }) : _gameService = gameService,
       _webSocketService = webSocketService,
       super(GameInitial()) {
    on<GameStarted>(_onGameStarted);
    on<GameTicked>(_onGameTicked);
    on<TickRateUpdated>(_onTickRateUpdated);
    on<PieceMoved>(_onPieceMoved);
    on<PieceRotated>(_onPieceRotated);
    on<PieceHardDropped>(_onPieceHardDropped);
    on<PieceLocked>(_onPieceLocked);
    on<PlayerScoreUpdated>(_onPlayerScoreUpdated);
    on<GarbageReceived>(_onGarbageReceived);
    on<PlayerDefeated>(_onPlayerDefeated);
    on<RefreshStandingsRequested>(_onRefreshStandingsRequested);
    on<GameOver>(_onGameOver);
    _listenToWebSockets();
  }

  void _listenToWebSockets() {
    _webSocketSubscription = _webSocketService.messages.listen((message) {
      final type = message['type'];
      final payload = message['payload'];
      switch (type) {
        case 'tickUpdate':
          if (payload?['newTickRate'] != null) {
            add(TickRateUpdated(payload['newTickRate']));
          }
          break;
        case 'playerScoreUpdated':
          if (payload?['userId'] != null && payload?['newScore'] != null) {
            add(
              PlayerScoreUpdated(
                userId: payload['userId'],
                newScore: payload['newScore'],
              ),
            );
          }
          break;
        case 'garbageReceived':
          if (payload?['lines'] != null) add(GarbageReceived(payload['lines']));
          break;
        case 'playerDefeated':
          if (payload?['userId'] != null) {
            add(PlayerDefeated(payload['userId']));
          }
          break;
        case 'gameOver':
          if (payload?['results'] != null) {
            final results = (payload['results'] as List)
                .map((r) => GameResult.fromJson(r))
                .toList();
            add(GameOver(results));
          }
          break;
      }
    });
  }

  void _startTimer() {
    _timer?.cancel();
    if (state is GameReady) {
      final currentState = state as GameReady;
      final fallInterval = (currentState.tickRate / gameBoardRows).round();
      _timer = Timer.periodic(Duration(milliseconds: fallInterval), (timer) {
        add(GameTicked());
      });
    }
  }

  Future<void> _onGameStarted(
    GameStarted event,
    Emitter<GameState> emit,
  ) async {
    emit(GameLoading());
    try {
      final initialState = await _gameService.getGameState(roomCode);
      final List<User> opponentsList = initialState['opponents'];
      final List<String> initialPieceQueue = initialState['pieceQueue'];

      final gameBoard = List.generate(
        gameBoardRows,
        (_) => List.generate(gameBoardCols, (_) => 0),
      );
      final opponentsMap = {
        for (var user in opponentsList) user.id: OpponentState(user: user),
      };
      final currentPiece = Piece(type: initialPieceQueue.first);
      final remainingQueue = initialPieceQueue.sublist(1);
      final initialPosition = const Position(row: -2, col: 4);

      emit(
        GameReady(
          gameBoard: gameBoard,
          opponents: opponentsMap,
          pieceQueue: remainingQueue,
          currentPiece: currentPiece,
          piecePosition: initialPosition,
        ),
      );

      _startTimer();
    } catch (e) {
      emit(GameError(e.toString()));
    }
  }

  void _onGameTicked(GameTicked event, Emitter<GameState> emit) {
    add(const PieceMoved(MoveDirection.down));
  }

  void _onPieceMoved(PieceMoved event, Emitter<GameState> emit) {
    if (state is GameReady) {
      final currentState = state as GameReady;
      if (currentState.currentPiece == null) return;
      Position newPosition = currentState.piecePosition!;
      switch (event.direction) {
        case MoveDirection.left:
          newPosition = Position(
            row: newPosition.row,
            col: newPosition.col - 1,
          );
          break;
        case MoveDirection.right:
          newPosition = Position(
            row: newPosition.row,
            col: newPosition.col + 1,
          );
          break;
        case MoveDirection.down:
          newPosition = Position(
            row: newPosition.row + 1,
            col: newPosition.col,
          );
          break;
      }

      if (_isValidPosition(
        newPosition,
        currentState.currentPiece!,
        currentState.gameBoard,
      )) {
        emit(currentState.copyWith(piecePosition: newPosition));
      } else if (event.direction == MoveDirection.down) {
        add(PieceLocked());
      }
    }
  }

  void _onPieceRotated(PieceRotated event, Emitter<GameState> emit) {
    if (state is GameReady) {
      final currentState = state as GameReady;
      if (currentState.currentPiece == null) return;

      final newRotation = (currentState.currentPiece!.rotation + 1) % 4;
      final newPiece = Piece(
        type: currentState.currentPiece!.type,
        rotation: newRotation,
      );

      if (_isValidPosition(
        currentState.piecePosition!,
        newPiece,
        currentState.gameBoard,
      )) {
        emit(currentState.copyWith(currentPiece: newPiece));
      } else if (_isValidPosition(
        Position(
          row: currentState.piecePosition!.row,
          col: currentState.piecePosition!.col - 1,
        ),
        newPiece,
        currentState.gameBoard,
      )) {
        emit(
          currentState.copyWith(
            currentPiece: newPiece,
            piecePosition: Position(
              row: currentState.piecePosition!.row,
              col: currentState.piecePosition!.col - 1,
            ),
          ),
        );
      } else if (_isValidPosition(
        Position(
          row: currentState.piecePosition!.row,
          col: currentState.piecePosition!.col + 1,
        ),
        newPiece,
        currentState.gameBoard,
      )) {
        emit(
          currentState.copyWith(
            currentPiece: newPiece,
            piecePosition: Position(
              row: currentState.piecePosition!.row,
              col: currentState.piecePosition!.col + 1,
            ),
          ),
        );
      }
    }
  }

  void _onPieceHardDropped(PieceHardDropped event, Emitter<GameState> emit) {
    if (state is GameReady) {
      final currentState = state as GameReady;
      if (currentState.currentPiece == null) return;

      Position dropPosition = currentState.piecePosition!;
      while (_isValidPosition(
        Position(row: dropPosition.row + 1, col: dropPosition.col),
        currentState.currentPiece!,
        currentState.gameBoard,
      )) {
        dropPosition = Position(
          row: dropPosition.row + 1,
          col: dropPosition.col,
        );
      }

      emit(currentState.copyWith(piecePosition: dropPosition));
      add(PieceLocked());
    }
  }

  Future<void> _onPieceLocked(
    PieceLocked event,
    Emitter<GameState> emit,
  ) async {
    if (state is GameReady) {
      final currentState = state as GameReady;

      bool hasToppedOut = false;
      final shapeMatrix =
          tetrominoShapes[currentState.currentPiece!.type]![currentState
              .currentPiece!
              .rotation];
      for (int r = 0; r < shapeMatrix.length; r++) {
        for (int c = 0; c < shapeMatrix[r].length; c++) {
          if (shapeMatrix[r][c] == 1) {
            if (currentState.piecePosition!.row + r < 0) {
              hasToppedOut = true;
              break;
            }
          }
        }
        if (hasToppedOut) break;
      }

      if (hasToppedOut) {
        _timer?.cancel();
        emit(currentState.copyWith(isPlayerDefeated: true));
        await _gameService.playerGameOver(roomCode);
        return;
      }

      // 1. Create a new board with the current piece "stamped" onto it.
      final boardWithStamp = _stampPiece(
        currentState.gameBoard,
        currentState.currentPiece!,
        currentState.piecePosition!,
      );

      // 2. Check for and clear any completed lines.
      final lineClearResult = _clearLines(boardWithStamp);
      var boardAfterClears = lineClearResult['board'] as List<List<int>>;
      final linesCleared = lineClearResult['linesCleared'] as int;

      int remainingGarbage = currentState.pendingGarbage;

      if (linesCleared > 0) {
        // If you cleared lines, they cancel out incoming garbage.
        remainingGarbage -= linesCleared;
        if (remainingGarbage < 0) remainingGarbage = 0;
      }

      if (remainingGarbage > 0) {
        boardAfterClears = _addGarbageLines(boardAfterClears, remainingGarbage);
        remainingGarbage = 0;
      }
      // 3. Calculate score and garbage.
      final scoreGained = _calculateScore(linesCleared);
      final garbageSent = _calculateGarbage(linesCleared);

      try {
        // 4. Report the action to the server and get the next pieces.
        final nextPiecesFromServer = await _gameService.reportAction(
          roomCode: roomCode,
          linesCleared: linesCleared,
          scoreGained: scoreGained,
          garbageSent: garbageSent,
        );

        // 5. Spawn the next piece from the queue.
        final newCurrentPiece = Piece(type: currentState.pieceQueue.first);
        final newPosition = const Position(row: -2, col: 4);

        // 6. Update the queue.
        final updatedQueue = List<String>.from(
          currentState.pieceQueue.sublist(1),
        )..addAll(nextPiecesFromServer);

        // 7. Check for Game Over (top out).
        if (!_isValidPosition(newPosition, newCurrentPiece, boardAfterClears)) {
          _timer?.cancel();
          await _gameService.playerGameOver(roomCode);
          return;
        }

        // 8. Emit the final, updated state for the next turn.
        emit(
          currentState.copyWith(
            gameBoard: boardAfterClears,
            score: currentState.score + scoreGained,
            linesCleared: currentState.linesCleared + linesCleared,
            currentPiece: newCurrentPiece,
            piecePosition: newPosition,
            pieceQueue: updatedQueue,
          ),
        );
      } catch (e) {
        emit(GameError(e.toString()));
      }
    }
  }

  void _onPlayerDefeated(PlayerDefeated event, Emitter<GameState> emit) {
    if (state is GameReady) {
      final currentState = state as GameReady;
      final newOpponentsMap = Map<String, OpponentState>.from(
        currentState.opponents,
      );
      if (newOpponentsMap.containsKey(event.userId)) {
        newOpponentsMap[event.userId] = newOpponentsMap[event.userId]!.copyWith(
          isDefeated: true,
        );
        emit(currentState.copyWith(opponents: newOpponentsMap));
      }
    }
  }

  void _onGameOver(GameOver event, Emitter<GameState> emit) {
    _timer?.cancel();
    emit(GameFinished(event.results));
  }

  void _onTickRateUpdated(TickRateUpdated event, Emitter<GameState> emit) {
    if (state is GameReady) {
      final currentState = state as GameReady;
      emit(currentState.copyWith(tickRate: event.newTickRate));
      _startTimer();
    }
  }

  void _onPlayerScoreUpdated(
    PlayerScoreUpdated event,
    Emitter<GameState> emit,
  ) {
    if (state is GameReady) {
      final currentState = state as GameReady;
      final opponentId = event.userId;
      if (currentState.opponents.containsKey(opponentId)) {
        final newOpponentsMap = Map<String, OpponentState>.from(
          currentState.opponents,
        );
        final opponentState = newOpponentsMap[opponentId]!;
        newOpponentsMap[opponentId] = opponentState.copyWith(
          score: event.newScore,
        );
        emit(currentState.copyWith(opponents: newOpponentsMap));
      }
    }
  }

  void _onGarbageReceived(GarbageReceived event, Emitter<GameState> emit) {
    if (state is GameReady) {
      final currentState = state as GameReady;
      emit(
        currentState.copyWith(
          pendingGarbage: currentState.pendingGarbage + event.lineCount,
        ),
      );
    }
  }

  Future<void> _onRefreshStandingsRequested(
    RefreshStandingsRequested event,
    Emitter<GameState> emit,
  ) async {
    if (state is GameReady) {
      final standings = await _gameService.getStandings(roomCode);
      emit((state as GameReady).copyWith(standings: standings));
    }
  }
  
// --- HELPER METHODS ---

  int _pieceTypeToInt(String type) {
    switch (type) {
      case 'I':
        return 1;
      case 'O':
        return 2;
      case 'T':
        return 3;
      case 'S':
        return 4;
      case 'Z':
        return 5;
      case 'J':
        return 6;
      case 'L':
        return 7;
      default:
        return 0;
    }
  }

  List<List<int>> _stampPiece(
    List<List<int>> board,
    Piece piece,
    Position pos,
  ) {
    // Create a deep copy of the board to avoid modifying the original state directly
    List<List<int>> newBoard = board.map((row) => List<int>.from(row)).toList();

    final shapeMatrix = tetrominoShapes[piece.type]![piece.rotation];
    final pieceValue = _pieceTypeToInt(piece.type);

    for (int r = 0; r < shapeMatrix.length; r++) {
      for (int c = 0; c < shapeMatrix[r].length; c++) {
        if (shapeMatrix[r][c] == 1) {
          int boardRow = pos.row + r;
          int boardCol = pos.col + c;

          // Ensure we only stamp within the visible board bounds
          if (boardRow >= 0 &&
              boardRow < gameBoardRows &&
              boardCol >= 0 &&
              boardCol < gameBoardCols) {
            newBoard[boardRow][boardCol] = pieceValue;
          }
        }
      }
    }
    return newBoard;
  }

  Map<String, dynamic> _clearLines(List<List<int>> board) {
    List<List<int>> boardAfterClear = [];
    int linesCleared = 0;

    // Iterate from the bottom row to the top
    for (int r = gameBoardRows - 1; r >= 0; r--) {
      final row = board[r];
      // A full line is one that does not contain any empty '0' cells
      bool isLineFull = !row.contains(0);

      if (isLineFull) {
        linesCleared++;
      } else {
        // If the line is not full, add it to the top of our new board list
        boardAfterClear.insert(0, row);
      }
    }

    // Add new empty rows at the top to replace the ones that were cleared
    for (int i = 0; i < linesCleared; i++) {
      boardAfterClear.insert(0, List.generate(gameBoardCols, (_) => 0));
    }

    return {'board': boardAfterClear, 'linesCleared': linesCleared};
  }

  List<List<int>> _addGarbageLines(List<List<int>> board, int lineCount) {
    List<List<int>> newBoard = board.sublist(lineCount);

    final random = Random();
    for (int i = 0; i < lineCount; i++) {
      int holePosition = random.nextInt(gameBoardCols);
      List<int> garbageRow = List.generate(gameBoardCols, (col) {
        return col == holePosition ? 0 : 8;
      });
      newBoard.add(garbageRow);
    }

    return newBoard;
  }

  int _calculateScore(int linesCleared) {
    switch (linesCleared) {
      case 1:
        return 100; // Single
      case 2:
        return 300; // Double
      case 3:
        return 500; // Triple
      case 4:
        return 800; // Tetris
      default:
        return 0;
    }
  }

  int _calculateGarbage(int linesCleared) {
    switch (linesCleared) {
      case 2:
        return 1;
      case 3:
        return 2;
      case 4:
        return 4;
      default:
        return 0;
    }
  }

  bool _isValidPosition(Position pos, Piece piece, List<List<int>> board) {
    final shapeMatrix = tetrominoShapes[piece.type]![piece.rotation];
    for (int r = 0; r < shapeMatrix.length; r++) {
      for (int c = 0; c < shapeMatrix[r].length; c++) {
        if (shapeMatrix[r][c] == 1) {
          int boardRow = pos.row + r;
          int boardCol = pos.col + c;
          if (boardCol < 0 ||
              boardCol >= gameBoardCols ||
              boardRow >= gameBoardRows) {
            return false;
          }
          if (boardRow >= 0 && board[boardRow][boardCol] != 0) return false;
        }
      }
    }
    return true;
  }

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    _timer?.cancel();
    return super.close();
  }
}
