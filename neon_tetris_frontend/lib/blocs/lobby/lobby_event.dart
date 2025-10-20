import 'package:equatable/equatable.dart';

abstract class LobbyEvent extends Equatable {
  const LobbyEvent();

  @override
  List<Object> get props => [];
}

// -- Ranked Matchmaking Events --

class JoinRankedQueueRequested extends LobbyEvent {
  final String queueType;
  const JoinRankedQueueRequested(this.queueType);

  @override
  List<Object> get props => [queueType];
}

class LeaveRankedQueueRequested extends LobbyEvent {}

// -- Casual Lobby Events --

class CreateCasualRoomRequested extends LobbyEvent {
  final int roomSize;
  const CreateCasualRoomRequested(this.roomSize);

  @override
  List<Object> get props => [roomSize];
}

class JoinCasualRoomRequested extends LobbyEvent {
  final String roomCode;
  const JoinCasualRoomRequested(this.roomCode);

  @override
  List<Object> get props => [roomCode];
}

// -- Server-Sent Events --

class MatchFoundReceived extends LobbyEvent {
  final String roomCode;
  const MatchFoundReceived(this.roomCode);

  @override
  List<Object> get props => [roomCode];
}
