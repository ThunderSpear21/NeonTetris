import 'package:equatable/equatable.dart';
import 'package:neon_tetris_frontend/models/user_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final User user;
  const ProfileLoadSuccess(this.user);
  @override
  List<Object> get props => [user];
}

class ProfileLoadFailure extends ProfileState {
  final String error;
  const ProfileLoadFailure(this.error);
}

class ProfileUpdating extends ProfileLoadSuccess {
  const ProfileUpdating(super.user);
}
