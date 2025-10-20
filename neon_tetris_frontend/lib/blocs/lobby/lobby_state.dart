import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/room_model.dart'; // Make sure to create this model

abstract class LobbyState extends Equatable {
  const LobbyState();

  @override
  List<Object> get props => [];
}

class LobbyInitial extends LobbyState {}

class LobbyLoading extends LobbyState {}

class InRankedQueue extends LobbyState {
  final String queueType;

  const InRankedQueue(this.queueType);

  @override
  List<Object> get props => [queueType];
}

class InCasualLobby extends LobbyState {
  final Room room;

  const InCasualLobby(this.room);

  @override
  List<Object> get props => [room];
}

class MatchFound extends LobbyState {
  final String roomCode;

  const MatchFound(this.roomCode);

  @override
  List<Object> get props => [roomCode];
}

class LobbyError extends LobbyState {
  final String message;

  const LobbyError(this.message);

  @override
  List<Object> get props => [message];
}