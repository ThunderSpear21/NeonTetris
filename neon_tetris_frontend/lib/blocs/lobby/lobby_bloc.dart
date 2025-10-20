import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_event.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_state.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_state.dart';
import 'package:neon_tetris_frontend/services/room_service.dart';
import 'package:neon_tetris_frontend/services/websocket_service.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  final AuthBloc _authBloc;
  final RoomService _roomService;
  final WebSocketService _webSocketService;
  StreamSubscription? _webSocketSubscription;

  LobbyBloc({
    required AuthBloc authBloc,
    required RoomService roomService,
    required WebSocketService webSocketService,
  }) : _authBloc = authBloc,
       _roomService = roomService,
       _webSocketService = webSocketService,
       super(LobbyInitial()) {
    on<JoinRankedQueueRequested>(_onJoinRankedQueueRequested);
    on<LeaveRankedQueueRequested>(_onLeaveRankedQueueRequested);
    on<CreateCasualRoomRequested>(_onCreateCasualRoomRequested);
    on<JoinCasualRoomRequested>(_onJoinCasualRoomRequested);
    on<MatchFoundReceived>(_onMatchFoundReceived);
    _listenToWebSockets();
  }

  void _listenToWebSockets() {
    _webSocketSubscription = _webSocketService.messages.listen((message) {
      final eventType = message['type'];
      final payload = message['payload'];

      if (eventType == 'matchFound' &&
          payload is Map &&
          payload['roomCode'] != null) {
        add(MatchFoundReceived(payload['roomCode']));
      }
    });
  }

  Future<void> _onJoinRankedQueueRequested(
    JoinRankedQueueRequested event,
    Emitter<LobbyState> emit,
  ) async {
    emit(LobbyLoading());
    try {
      await _roomService.joinRankedQueue(event.queueType);
      emit(InRankedQueue(event.queueType));
    } catch (e) {
      emit(LobbyError(e.toString()));
    }
  }

  Future<void> _onLeaveRankedQueueRequested(
    LeaveRankedQueueRequested event,
    Emitter<LobbyState> emit,
  ) async {
    if (state is InRankedQueue) {
      final currentQueue = (state as InRankedQueue).queueType;
      emit(LobbyLoading());
      try {
        await _roomService.leaveRankedQueue(currentQueue);
        emit(LobbyInitial());
      } catch (e) {
        emit(LobbyError(e.toString()));
        emit(InRankedQueue(currentQueue));
      }
    }
  }

  Future<void> _onCreateCasualRoomRequested(
    CreateCasualRoomRequested event,
    Emitter<LobbyState> emit,
  ) async {
    emit(LobbyLoading());
    try {
      final room = await _roomService.createCasualRoom(event.roomSize);
      final userId = (_authBloc.state as Authenticated).user.id;
      _webSocketService.sendMessage('JOIN_ROOM', {
        'roomCode': room.roomCode,
        'userId': userId,
      });
      emit(InCasualLobby(room));
    } catch (e) {
      emit(LobbyError(e.toString()));
    }
  }

  Future<void> _onJoinCasualRoomRequested(
    JoinCasualRoomRequested event,
    Emitter<LobbyState> emit,
  ) async {
    emit(LobbyLoading());
    try {
      final room = await _roomService.joinCasualRoom(event.roomCode);
      final userId = (_authBloc.state as Authenticated).user.id;
      _webSocketService.sendMessage('JOIN_ROOM', {
        'roomCode': room.roomCode,
        'userId': userId,
      });
      emit(InCasualLobby(room));
    } catch (e) {
      emit(LobbyError(e.toString()));
    }
  }

  void _onMatchFoundReceived(
    MatchFoundReceived event,
    Emitter<LobbyState> emit,
  ) {
    emit(MatchFound(event.roomCode));
  }

  @override
  Future<void> close() {
    _webSocketSubscription?.cancel();
    return super.close();
  }
}
