import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoggedOut extends AuthEvent {}

class LoggedIn extends AuthEvent {}

class UserUpdated extends AuthEvent {
  final User updatedUser;

  const UserUpdated(this.updatedUser);

  @override
  List<Object> get props => [updatedUser];
}