import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/profile/profile_event.dart';
import 'package:neon_tetris_frontend/blocs/profile/profile_state.dart';
import 'package:neon_tetris_frontend/services/user_service.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileFetched>(_onProfileFetched);
    on<AvatarUpdateRequested>(_onAvatarUpdateRequested);
  }

  Future<void> _onProfileFetched(
    ProfileFetched event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await UserService.getCurrentUser();
      emit(ProfileLoadSuccess(user));
    } catch (e) {
      emit(ProfileLoadFailure(e.toString()));
    }
  }

  Future<void> _onAvatarUpdateRequested(
    AvatarUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoadSuccess) {
      final currentUser = (state as ProfileLoadSuccess).user;
      emit(ProfileUpdating(currentUser));
      try {
        final updatedUser = await UserService.updateAvatar(event.imageBytes, event.filename);
        emit(ProfileLoadSuccess(updatedUser));
      } catch (e) {
        emit(ProfileLoadFailure(e.toString()));
        emit(ProfileLoadSuccess(currentUser));
      }
    }
  }
}
