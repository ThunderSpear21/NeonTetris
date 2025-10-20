import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:neon_tetris_frontend/blocs/leaderboard/leaderboard_event.dart';
import 'package:neon_tetris_frontend/blocs/leaderboard/leaderboard_state.dart';
import 'package:neon_tetris_frontend/models/leaderboard_entry_model.dart';

class ViewLeaderboardScreen extends StatefulWidget {
  const ViewLeaderboardScreen({super.key});

  @override
  State<ViewLeaderboardScreen> createState() => _ViewLeaderboardScreenState();
}

class _ViewLeaderboardScreenState extends State<ViewLeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<LeaderboardBloc>().add(LeaderboardFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Leaderboard'),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton.outlined(
              onPressed: () =>
                  context.read<LeaderboardBloc>().add(LeaderboardFetched()),
              icon: Icon(Icons.refresh),
              iconSize: 20,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/neon-tetris-1.png", fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),
          BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoading || state is LeaderboardInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is LeaderboardLoadFailure) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<LeaderboardBloc>().add(
                          LeaderboardFetched(),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }
              if (state is LeaderboardLoadSuccess) {
                if (state.leaderboard.isEmpty) {
                  return const Center(child: Text('The leaderboard is empty.'));
                }
                return _LeaderboardList(leaderboard: state.leaderboard);
              }
              return const Center(child: Text('Something went wrong.'));
            },
          ),
        ],
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<LeaderboardEntry> leaderboard;
  const _LeaderboardList({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget getRankIcon(int rank) {
      switch (rank) {
        case 1:
          return const Icon(Icons.emoji_events, color: Colors.amber);
        case 2:
          return const Icon(
            Icons.emoji_events,
            color: Color(0xFFC0C0C0),
          ); 
        case 3:
          return const Icon(
            Icons.emoji_events,
            color: Color(0xFFCD7F32),
          ); 
        default:
          return Text('$rank.', style: theme.textTheme.titleMedium);
      }
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final entry = leaderboard[index];
            final rank = index + 1;

            return Card(
              elevation: 4,
              child: ListTile(
                leading: SizedBox(
                  width: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [getRankIcon(rank)],
                  ),
                ),
                title: Text(entry.username, style: theme.textTheme.titleMedium),
                subtitle: Text('Games Played: ${entry.gamesPlayed}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.gamesWon} Wins',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text('Score: ${entry.highestScore}'),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
