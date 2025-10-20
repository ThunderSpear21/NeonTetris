import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:neon_tetris_frontend/blocs/profile/profile_bloc.dart';
import 'package:neon_tetris_frontend/blocs/profile/profile_event.dart';
import 'package:neon_tetris_frontend/blocs/profile/profile_state.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileFetched());
  }

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  Future<void> _pickAndUploadAvatar(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final filename = pickedFile.name;
      // ignore: use_build_context_synchronously
      context.read<ProfileBloc>().add(
            AvatarUpdateRequested(imageBytes: bytes, filename: filename),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoadFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileLoadSuccess) {
            final user = state.user;
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.asset("assets/neon-tetris-1.png", fit: BoxFit.cover),
                ),
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.7)),
                ),
                SingleChildScrollView(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  child: user.avatarUrl == null ? const Icon(Icons.person, size: 60) : null,
                                ),
                                Positioned.fill(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(60),
                                      onTap: state is ProfileUpdating ? null : () => _pickAndUploadAvatar(context),
                                      child: Center(child: Icon(Icons.edit, color: Colors.white.withValues(alpha: 0.7), size: 30)),
                                    ),
                                  ),
                                ),
                                if (state is ProfileUpdating)
                                  const Positioned.fill(child: CircularProgressIndicator(color: Colors.white)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(user.username, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
                            Text(user.email ?? '', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey)),
                            const Divider(height: 40),
                            
                            _StatsSection(title: 'Ranked Stats', stats: user.rankedStats),
                            const SizedBox(height: 24),

                            _StatsSection(title: 'Unranked Stats', stats: user.unrankedStats),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('Could not load profile.'));
        },
      ),
    );
  }
}


class _StatsSection extends StatelessWidget {
  final String title;
  final GameStats? stats;
  const _StatsSection({required this.title, this.stats});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                _StatCard(label: 'Games Played', value: stats?.gamesPlayed.toString() ?? '0'),
                _StatCard(label: 'Games Won', value: stats?.gamesWon.toString() ?? '0'),
                _StatCard(label: 'Lines Cleared', value: stats?.linesCleared.toString() ?? '0'),
                _StatCard(label: 'Highest Score', value: stats?.highestScore.toString() ?? '0'),
              ],
            )
          ],
        ),
      ),
    );
  }
}


class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: theme.textTheme.labelLarge, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(value, style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.primary)),
          ],
        ),
      ),
    );
  }
}