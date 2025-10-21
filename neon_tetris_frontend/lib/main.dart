import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/leaderboard/leaderboard_bloc.dart';
import 'package:neon_tetris_frontend/blocs/profile/profile_bloc.dart';
import 'package:neon_tetris_frontend/constants.dart';
import 'package:neon_tetris_frontend/services/game_service.dart';
import 'package:provider/provider.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_event.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_state.dart';
import 'package:neon_tetris_frontend/blocs/lobby/lobby_bloc.dart';
import 'package:neon_tetris_frontend/blocs/login/login_bloc.dart';
import 'package:neon_tetris_frontend/blocs/register/register_bloc.dart';
import 'package:neon_tetris_frontend/blocs/settings/settings_bloc.dart';
import 'package:neon_tetris_frontend/blocs/theme/theme_bloc.dart';
import 'package:neon_tetris_frontend/blocs/theme/theme_state.dart';
import 'package:neon_tetris_frontend/blocs/verify_email/verify_email_bloc.dart';
import 'package:neon_tetris_frontend/screens/auth_wrapper.dart';
import 'package:neon_tetris_frontend/services/audio_service.dart';
import 'package:neon_tetris_frontend/services/room_service.dart';
import 'package:neon_tetris_frontend/services/session_manager.dart';
import 'package:neon_tetris_frontend/services/websocket_service.dart';
import 'package:neon_tetris_frontend/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await AudioService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<RoomService>(create: (_) => RoomService()),
        Provider<WebSocketService>(create: (_) => WebSocketService()),
        Provider<GameService>(create: (_) => GameService()),

        BlocProvider<AuthBloc>(create: (_) => AuthBloc()..add(AppStarted())),
        BlocProvider<LobbyBloc>(
          create: (context) => LobbyBloc(
            authBloc: context.read<AuthBloc>(),
            roomService: context.read<RoomService>(),
            webSocketService: context.read<WebSocketService>(),
          ),
        ),


        BlocProvider(create: (_) => ThemeBloc()),
        BlocProvider(create: (_) => SettingsBloc()),
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => VerifyEmailBloc()),
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
        BlocProvider(create: (_) => LeaderboardBloc())
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) async {
          final webSocketService = context.read<WebSocketService>();

          if (state is Authenticated) {
            final token = await SessionManager.getAccessToken();
            if (token != null) {
              final httpUri = Uri.parse(BASE_URL);
              final wsUrl = Uri(
                scheme: 'wss',
                host: httpUri.host,
                path: '/ws',
                queryParameters: {'token': token},
              ).toString();
              webSocketService.connect(wsUrl);
            }
            AudioService().playLoopingMusic('bgm.mp3');
          } else if (state is Unauthenticated) {
            AudioService().stopMusic();
            webSocketService.disconnect();
          }
        },
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, state) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Neon-Tetris',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.themeMode,
              home: AuthWrapper()
            );
          },
        ),
      ),
    );
  }
}
