import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/theme/theme_event.dart';
import 'package:neon_tetris_frontend/blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(ThemeMode.dark)) {
    on<ThemeToggled>((event, emit) {
      if (state.themeMode == ThemeMode.light) {
        emit(const ThemeState(ThemeMode.dark));
      } else {
        emit(const ThemeState(ThemeMode.light));
      }
    });
  }
}
