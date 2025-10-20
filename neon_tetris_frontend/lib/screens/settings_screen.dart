import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_event.dart';
import 'package:neon_tetris_frontend/blocs/settings/settings_bloc.dart';
import 'package:neon_tetris_frontend/blocs/settings/settings_event.dart';
import 'package:neon_tetris_frontend/blocs/settings/settings_state.dart';
import 'package:neon_tetris_frontend/blocs/theme/theme_bloc.dart';
import 'package:neon_tetris_frontend/blocs/theme/theme_event.dart';
import 'package:neon_tetris_frontend/screens/view_profile_screen.dart';
import 'package:neon_tetris_frontend/services/audio_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text("Settings"), centerTitle: true),
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
                              text: 'Profile',
                              icon: Icons.person,

                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProfileScreen(),
                                  ),
                                );
                              },
                              color: colorScheme.primary,
                            ),
                            const SizedBox(height: 20),
                            _MenuButton(
                              text:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? 'Dark Mode'
                                  : 'Light Mode',
                              icon:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Icons.dark_mode
                                  : Icons.light_mode,

                              onPressed: () {
                                context.read<ThemeBloc>().add(ThemeToggled());
                              },
                              color: colorScheme.secondary,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Music',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.volume_off, color: Colors.white),
                                BlocBuilder<SettingsBloc, SettingsState>(
                                  builder: (context, state) {
                                    return Expanded(
                                      child: Slider(
                                        value: state.musicVolume,
                                        onChanged: (volume) {
                                          context.read<SettingsBloc>().add(
                                            MusicVolumeChanged(volume),
                                          );
                                          AudioService().setVolume(volume);
                                        },
                                        activeColor: colorScheme.tertiary,
                                      ),
                                    );
                                  },
                                ),
                                Icon(Icons.volume_up, color: Colors.white),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _MenuButton(
                              text: 'Log Out',
                              icon: Icons.power_settings_new,
                              onPressed: () {
                                context.read<AuthBloc>().add(LoggedOut());
                                Navigator.of(
                                  context,
                                ).popUntil((route) => route.isFirst);
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
