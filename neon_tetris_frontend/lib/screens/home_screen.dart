import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_state.dart';
import 'package:neon_tetris_frontend/screens/casual_mode_screen.dart';
import 'package:neon_tetris_frontend/screens/ranked_mode_screen.dart';
import 'package:neon_tetris_frontend/screens/settings_screen.dart';
import 'package:neon_tetris_frontend/screens/view_leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Neon Tetris'), centerTitle: true),
      body: LayoutBuilder(
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
                  Positioned(
                    left: 20,
                    top: 20,
                    child: BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is Authenticated) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 32.0),
                            child: Text(
                              'Welcome, ${state.user.username} !',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _MenuButton(
                              text: 'Ranked Match',
                              icon: Icons.emoji_events,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const RankedModeScreen(),
                                  ),
                                );
                              },
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            _MenuButton(
                              text: 'Casual Match',
                              icon: Icons.gamepad,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const CasualModeScreen(),
                                  ),
                                );
                              },
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(height: 20),
                            _MenuButton(
                              text: 'Leaderboard',
                              icon: Icons.leaderboard,
                              onPressed: () {Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ViewLeaderboardScreen(),
                                  ),
                                );},
                              color: colorScheme.tertiary,
                            ),
                            const SizedBox(height: 20),
                            _MenuButton(
                              text: 'Settings',
                              icon: Icons.settings,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsScreen(),
                                  ),
                                );
                              },
                              color: Colors.grey.shade600,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
