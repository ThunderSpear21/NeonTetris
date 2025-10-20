import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/room_model.dart';

abstract class RoomState extends Equatable {
  const RoomState();
  @override
  List<Object> get props => [];
}

class RoomInitial extends RoomState {}

class RoomLoading extends RoomState {}

class RoomLoaded extends RoomState {
  final Room room;
  const RoomLoaded(this.room);
  @override
  List<Object> get props => [room];
}

class NavigatingToGame extends RoomState {
  final String roomCode;
  const NavigatingToGame(this.roomCode);

  @override
  List<Object> get props => [roomCode];
}

class RoomError extends RoomState {
  final String message;
  const RoomError(this.message);
}

class KickedFromRoom extends RoomState{}