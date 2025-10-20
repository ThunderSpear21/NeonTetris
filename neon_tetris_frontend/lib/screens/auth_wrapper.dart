import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_state.dart';
import 'package:neon_tetris_frontend/screens/home_screen.dart';
import 'package:neon_tetris_frontend/screens/login_screen.dart';
import 'package:neon_tetris_frontend/screens/title_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const HomeScreen();
        }
        if (state is Unauthenticated) {
          return const LoginScreen();
        }
        return const TitleScreen();
      },
    );
  }
}