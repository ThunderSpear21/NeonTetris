import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/room/room_event.dart';
import 'package:neon_tetris_frontend/blocs/room/room_state.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';
import 'package:neon_tetris_frontend/services/room_service.dart';
import 'package:neon_tetris_frontend/services/websocket_service.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  // ignore: unused_field
  final RoomService _roomService;
  final WebSocketService _webSocketService;
  StreamSubscription? _webSocketSubscription;

  RoomBloc({
    required RoomService roomService,
    required WebSocketService webSocketService,
  }) : _roomService = roomService,
       _webSocketService = webSocketService,
       super(RoomInitial()) {
    on<RoomInitialized>((event, emit) => emit(RoomLoaded(event.room)));
    on<PlayerJoined>(_onPlayerJoined);
    on<PlayerLeft>(_onPlayerLeft);
    on<LeaveRoomRequested>(_onLeaveRoomRequested);
    on<StartGameRequested>(_onStartGameRequested);
    on<RoomStartedReceived>(
      (event, emit) => emit(NavigatingToGame(event.roomCode)),
    );
    on<RoomWasClosed>((event, emit) => emit(KickedFromRoom()));
    _listenToWebSockets();
  }

  void _listenToWebSockets() {
    _webSocketSubscription = _webSocketService.messages.listen((message) {
      final eventType = message['type'];
      final payload = message['payload'];
      if (eventType == 'playerJoined' && payload != null) {
        add(PlayerJoined(User.fromJson(payload)));
      } else if (eventType == 'playerLeft' && payload?['userId'] != null) {
        add(PlayerLeft(payload['userId']));
      } else if (eventType == 'roomStarted' && payload['roomCode'] != null) {
        add(RoomStartedReceived(payload['roomCode']));
      } else if(eventType == 'roomClosed' && payload['roomCode'] != null){
        add(RoomWasClosed());
      }
    });
  }

  void _onPlayerJoined(PlayerJoined event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentRoom = (state as RoomLoaded).room;
      final bool playerExists = currentRoom.players.any(
        (p) => p.id == event.user.id,
      );
      if (playerExists) {
        return;
      }
      final updatedPlayers = List<User>.from(currentRoom.players);
      updatedPlayers.add(event.user);
      final newRoom = currentRoom.copyWith(players: updatedPlayers);
      emit(RoomLoaded(newRoom));
    }
  }

  void _onPlayerLeft(PlayerLeft event, Emitter<RoomState> emit) {
    if (state is RoomLoaded) {
      final currentRoom = (state as RoomLoaded).room;
      final updatedPlayers = List<User>.from(currentRoom.players)
        ..removeWhere((player) => player.id == event.userId);
      emit(RoomLoaded(currentRoom.copyWith(players: updatedPlayers)));
    }
  }

  Future<void> _onLeaveRoomRequested(
    LeaveRoomRequested event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoaded) {
      final roomCode = (state as RoomLoaded).room.roomCode;
      try {
        await _roomService.leaveCasualRoom(roomCode);
      } catch (e) {
        //print("Error leaving room: $e");
      }
    }
  }

  Future<void> _onStartGameRequested(
    StartGameRequested event,
    Emitter<RoomState> emit,
  ) async {
    if (state is RoomLoaded) {
      final roomCode = (state as RoomLoaded).room.roomCode;
      try {
        await _roomService.startRoom(roomCode);
      } catch (e) {
        emit(RoomError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    return super.close();
  }
}
