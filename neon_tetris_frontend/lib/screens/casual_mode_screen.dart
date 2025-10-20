import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_bloc.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_event.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_state.dart';
import 'package:neon_tetris_frontend/screens/lobby_screen.dart';

class CasualModeScreen extends StatelessWidget {
  const CasualModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Casual Mode'), centerTitle: true),
      body: BlocConsumer<LobbyBloc, LobbyState>(
        listener: (context, state) {
          if (state is LobbyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is InCasualLobby) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => LobbyScreen(initialRoom: state.room),
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
                      if (state is LobbyLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        const _ModeSelectionView(),
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
  const _ModeSelectionView();

  void _showCreateLobbyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<LobbyBloc>(context),
          child: const _CreateLobbyDialogContent(),
        );
      },
    );
  }

  void _showJoinLobbyDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) {
        return BlocProvider.value(
          value: BlocProvider.of<LobbyBloc>(context),
          child: const _JoinLobbyDialogContent(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _MenuButton(
                text: 'Create Lobby',
                icon: Icons.add_box_outlined,
                onPressed: () => _showCreateLobbyDialog(context),
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Join Lobby',
                icon: Icons.input,
                onPressed: () => _showJoinLobbyDialog(context),
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 20),
              _MenuButton(
                text: 'Duel a Friend',
                icon: Icons.people_alt_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Feature yet to be rolled out !!"),
                      backgroundColor: colorScheme.error,
                      duration: Duration(milliseconds: 500),
                    ),
                  );
                },
                color: colorScheme.tertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateLobbyDialogContent extends StatefulWidget {
  const _CreateLobbyDialogContent();
  @override
  State<_CreateLobbyDialogContent> createState() =>
      _CreateLobbyDialogContentState();
}

class _CreateLobbyDialogContentState extends State<_CreateLobbyDialogContent> {
  int _selectedSize = 2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = [
      _selectedSize == 2,
      _selectedSize == 3,
      _selectedSize == 4,
    ];

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.primary, width: 2),
      ),
      title: Center(
        child: Text(
          'Create Casual Lobby',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.primary,
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Select lobby size:', style: theme.textTheme.bodyLarge),
          const SizedBox(height: 16),
          ToggleButtons(
            isSelected: isSelected,
            onPressed: (index) => setState(() => _selectedSize = index + 2),
            borderRadius: BorderRadius.circular(8),
            selectedColor: colorScheme.onPrimary,
            color: colorScheme.primary,
            fillColor: colorScheme.primary,
            borderColor: colorScheme.primary,
            selectedBorderColor: colorScheme.primary,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('2P'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('3P'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('4P'),
              ),
            ],
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            context.read<LobbyBloc>().add(
              CreateCasualRoomRequested(_selectedSize),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

class _JoinLobbyDialogContent extends StatelessWidget {
  const _JoinLobbyDialogContent();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final roomCodeController = TextEditingController();

    return AlertDialog(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.secondary, width: 2),
      ),
      title: Center(
        child: Text(
          'Join Casual Lobby',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.secondary,
          ),
        ),
      ),
      content: TextField(
        controller: roomCodeController,
        decoration: const InputDecoration(labelText: 'Enter Room Code'),
        style: TextStyle(color: theme.colorScheme.onSurface),
        textAlign: TextAlign.center,
        autofocus: true,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondary,
          ),
          onPressed: () {
            final roomCode = roomCodeController.text.trim().toUpperCase();
            if (roomCode.isNotEmpty) {
              context.read<LobbyBloc>().add(JoinCasualRoomRequested(roomCode));
              Navigator.of(context).pop();
            }
          },
          child: const Text('Join'),
        ),
      ],
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
      icon: Icon(icon),
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
