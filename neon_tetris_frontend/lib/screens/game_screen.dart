import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/game/game_bloc.dart';
import 'package:neon_tetris_frontend/blocs/game/game_event.dart';
import 'package:neon_tetris_frontend/blocs/game/game_state.dart';
import 'package:neon_tetris_frontend/models/game_result_model.dart';
import 'package:neon_tetris_frontend/models/live_standing_model.dart';
import 'package:neon_tetris_frontend/services/game_service.dart';
import 'package:neon_tetris_frontend/services/websocket_service.dart';
import 'package:neon_tetris_frontend/widgets/tetris_board.dart';

class GameScreen extends StatelessWidget {
  final String roomCode;
  const GameScreen({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(
        roomCode: roomCode,
        gameService: context.read<GameService>(),
        webSocketService: context.read<WebSocketService>(),
      )..add(GameStarted()),
      child: const _GameView(),
    );
  }
}


class _GameView extends StatelessWidget {
  const _GameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          if (state is GameLoading || state is GameInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is GameFinished) {
            return _GameResultsView(results: state.results);
          }
          if (state is GameReady) {
            return Stack(
              children: [
                Focus(
                  autofocus: true,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent) {
                      final gameBloc = context.read<GameBloc>();
                      if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                        gameBloc.add(const PieceMoved(MoveDirection.left));
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowRight) {
                        gameBloc.add(const PieceMoved(MoveDirection.right));
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowDown) {
                        gameBloc.add(const PieceMoved(MoveDirection.down));
                      } else if (event.logicalKey ==
                          LogicalKeyboardKey.arrowUp) {
                        gameBloc.add(PieceRotated());
                      } else if (event.logicalKey == LogicalKeyboardKey.space) {
                        gameBloc.add(PieceHardDropped());
                      }
                    }
                    return KeyEventResult.handled;
                  },
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _OpponentBoardsPanel(
                              opponents: state.opponents,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 5,
                            child: _MainGameBoard(
                              gameBoard: state.gameBoard,
                              currentPiece: state.currentPiece,
                              piecePosition: state.piecePosition,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _GameInfoPanel(
                              score: state.score,
                              linesCleared: state.linesCleared,
                              nextPiece: state.pieceQueue.isNotEmpty
                                  ? state.pieceQueue.first
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                if (state.isPlayerDefeated)
                  _LiveStandingsOverlay(standings: state.standings ?? []),
              ],
            );
          }
          return Center(
            child: Text('An error occurred: ${(state as GameError).message}'),
          );
        },
      ),
    );
  }
}



class _OpponentBoardsPanel extends StatelessWidget {
  final Map<String, OpponentState> opponents;
  const _OpponentBoardsPanel({required this.opponents});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: opponents.values
          .map((op) => _OpponentBoardView(opponent: op))
          .toList(),
    );
  }
}

class _OpponentBoardView extends StatelessWidget {
  final OpponentState opponent;
  const _OpponentBoardView({required this.opponent});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(opponent.user.username),
        subtitle: Text('Score: ${opponent.score}'),
        trailing: opponent.isDefeated
            ? const Icon(Icons.close, color: Colors.red)
            : null,
      ),
    );
  }
}

class _MainGameBoard extends StatelessWidget {
  final List<List<int>> gameBoard;
  final Piece? currentPiece;
  final Position? piecePosition;

  const _MainGameBoard({
    required this.gameBoard,
    required this.currentPiece,
    required this.piecePosition,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [const Color.fromARGB(255, 13, 3, 23), Colors.black]
        : [const Color.fromARGB(255, 254, 225, 225), const Color.fromARGB(255, 248, 238, 234)];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("TETRIS", style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: gradientColors,
                center: Alignment.center,
                radius: 1.0,
              ),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.7),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: TetrisBoard(
              gameBoard: gameBoard,
              currentPiece: currentPiece,
              piecePosition: piecePosition,
            ),
          ),
        ),
      ],
    );
  }
}

class _GameInfoPanel extends StatelessWidget {
  final int score;
  final int linesCleared;
  final String? nextPiece;

  const _GameInfoPanel({
    required this.score,
    required this.linesCleared,
    this.nextPiece,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('SCORE'),
                Text(
                  '$score',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text('NEXT'),
                if (nextPiece != null)
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: TetrisBoard(
                      rows: 4,
                      cols: 4,
                      gameBoard: List.generate(
                        4,
                        (_) => List.generate(4, (_) => 0),
                      ),
                      currentPiece: Piece(type: nextPiece!),
                      piecePosition: const Position(row: 0, col: 0),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LiveStandingsOverlay extends StatelessWidget {
  final List<LiveStanding> standings;
  const _LiveStandingsOverlay({required this.standings});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You've been eliminated!",
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),
            const Text(
              "Live Standings",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: standings.length,
                itemBuilder: (context, index) {
                  final standing = standings[index];
                  return ListTile(
                    leading: Text(
                      '${standing.placement}.',
                      style: const TextStyle(color: Colors.white),
                    ),
                    title: Text(
                      standing.username,
                      style: TextStyle(
                        color: standing.isAlive ? Colors.white : Colors.grey,
                      ),
                    ),
                    trailing: Text(
                      '${standing.score}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.read<GameBloc>().add(RefreshStandingsRequested()),
                  child: const Text('Refresh'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Return to Menu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GameResultsView extends StatelessWidget {
  final List<GameResult> results;
  const _GameResultsView({required this.results});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'GAME OVER',
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 8,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final result = results[index];
                  final isWinner = result.placement == 1;

                  return ListTile(
                    leading: Text(
                      '${index+1}.',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: isWinner ? Colors.amber : null,
                      ),
                    ),
                    title: Text(
                      result.username,
                      style: TextStyle(
                        fontWeight: isWinner
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    trailing: Text(
                      '${result.score}',
                      style: theme.textTheme.titleMedium,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Return to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
