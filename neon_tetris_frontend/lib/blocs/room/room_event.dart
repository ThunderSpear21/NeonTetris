import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';
import 'package:neon_tetris_frontend/models/room_model.dart';

abstract class RoomEvent extends Equatable {
  const RoomEvent();
  @override
  List<Object> get props => [];
}

class RoomInitialized extends RoomEvent {
  final Room room;
  const RoomInitialized(this.room);
}

class PlayerJoined extends RoomEvent {
  final User user;
  const PlayerJoined(this.user);
}

class PlayerLeft extends RoomEvent {
  final String userId;
  const PlayerLeft(this.userId);
}

class LeaveRoomRequested extends RoomEvent {}

class StartGameRequested extends RoomEvent {}

class RoomStartedReceived extends RoomEvent {
  final String roomCode;
  const RoomStartedReceived(this.roomCode);

  @override
  List<Object> get props => [roomCode];
}

class RoomWasClosed extends RoomEvent{}
