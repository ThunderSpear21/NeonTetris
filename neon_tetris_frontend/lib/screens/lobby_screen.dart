import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_state.dart';
import 'package:neon_tetris_frontend/blocs/room/room_bloc.dart';
import 'package:neon_tetris_frontend/blocs/room/room_event.dart';
import 'package:neon_tetris_frontend/blocs/room/room_state.dart';
import 'package:neon_tetris_frontend/models/room_model.dart';
import 'package:neon_tetris_frontend/screens/game_screen.dart';
import 'package:neon_tetris_frontend/services/room_service.dart';
import 'package:neon_tetris_frontend/services/websocket_service.dart';

class LobbyScreen extends StatelessWidget {
  final Room initialRoom;
  const LobbyScreen({super.key, required this.initialRoom});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomBloc(
        roomService: context.read<RoomService>(),
        webSocketService: context.read<WebSocketService>(),
      )..add(RoomInitialized(initialRoom)),
      child: const _LobbyView(),
    );
  }
}

class _LobbyView extends StatelessWidget {
  const _LobbyView();

  @override
  Widget build(BuildContext context) {
    final currentUserId =
        (context.watch<AuthBloc>().state as Authenticated).user.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Casual Lobby'),
        automaticallyImplyLeading: false,
      ),
      body: BlocListener<RoomBloc, RoomState>(
        listener: (context, state) {
          if (state is NavigatingToGame) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => GameScreen(roomCode: state.roomCode),
              ),
            );
          } else if (state is KickedFromRoom) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('The host has closed the lobby.'),
                duration: Duration(milliseconds: 600),
              ),
            );
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<RoomBloc, RoomState>(
          builder: (context, state) {
            if (state is RoomLoaded) {
              final room = state.room;
              final isHost = currentUserId == room.hostId;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                const Text(
                                  'ROOM CODE',
                                  style: TextStyle(letterSpacing: 2),
                                ),
                                const SizedBox(height: 8),
                                SelectableText(
                                  room.roomCode,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.copy, size: 16),
                                  label: const Text('Copy'),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: room.roomCode),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Room code copied!'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Players (${room.players.length}/${room.maxPlayers})',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const Divider(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: room.players.length,
                            itemBuilder: (context, index) {
                              final player = room.players[index];
                              final isPlayerHost = player.id == room.hostId;
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Image.network(player.avatarUrl!),
                                ),
                                title: Text(player.username),
                                trailing: isPlayerHost
                                    ? const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  context.read<RoomBloc>().add(
                                    LeaveRoomRequested(),
                                  );
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Leave'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (isHost)
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    context.read<RoomBloc>().add(
                                      StartGameRequested(),
                                    );
                                  },
                                  child: const Text('Start Game'),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
