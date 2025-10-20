import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_bloc.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_event.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_state.dart';
import 'package:neon_tetris_frontend/screens/game_screen.dart';

class RankedQueueType {
  final String text;
  final IconData icon;
  final Color color;
  final String queueApiIdentifier;

  RankedQueueType({
    required this.text,
    required this.icon,
    required this.color,
    required this.queueApiIdentifier,
  });
}

class RankedModeScreen extends StatelessWidget {
  const RankedModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ranked Mode'), centerTitle: true),
      body: BlocConsumer<LobbyBloc, LobbyState>(
        listener: (context, state) {
          if (state is LobbyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MatchFound) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameScreen(roomCode: state.roomCode),
              ),
            );
          }
        },
        builder: (context, state) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          "assets/neon-tetris-1.png",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.black.withValues(alpha: 0.4),
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                      if (state is InRankedQueue)
                        _QueueingView()
                      else if (state is LobbyLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        _ModeSelectionView(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ModeSelectionView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<RankedQueueType> rankedQueues = [
      RankedQueueType(
        text: '2 Player',
        icon: Icons.person_2_outlined,
        color: colorScheme.primary,
        queueApiIdentifier: '2P',
      ),
      RankedQueueType(
        text: '3 Player',
        icon: Icons.person_3_outlined,
        color: colorScheme.secondary,
        queueApiIdentifier: '3P',
      ),
      RankedQueueType(
        text: '4 Player',
        icon: Icons.person_4_outlined,
        color: colorScheme.tertiary,
        queueApiIdentifier: '4P',
      ),
      RankedQueueType(
        text: 'Quick Queue',
        icon: Icons.fast_forward,
        color: Colors.grey.shade600,
        queueApiIdentifier: 'quick',
      ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: rankedQueues.length,
            separatorBuilder: (context, index) => const SizedBox(height: 20),
            itemBuilder: (context, index) {
              final queue = rankedQueues[index];
              return _MenuButton(
                text: queue.text,
                icon: queue.icon,
                onPressed: () {
                  context.read<LobbyBloc>().add(
                    JoinRankedQueueRequested(queue.queueApiIdentifier),
                  );
                },
                color: queue.color,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QueueingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Card(
        color: Colors.black.withValues(alpha: 0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Searching for match...',
                style: textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  context.read<LobbyBloc>().add(LeaveRankedQueueRequested());
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;

  const _MenuButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(text, style: const TextStyle(fontSize: 20)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: color.withValues(alpha: 0.85),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 2),
        ),
        elevation: 8,
        shadowColor: color.withValues(alpha: 0.5),
      ),
    );
  }
}
