import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/settings/settings_event.dart';
import 'package:neon_tetris_frontend/blocs/settings/settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(const SettingsState()) {
    on<HapticsToggled>((event, emit) {
      emit(state.copyWith(isHapticsEnabled: !state.isHapticsEnabled));
    });

    on<MusicVolumeChanged>((event, emit) {
      emit(state.copyWith(musicVolume: event.volume));
    });
  }
}