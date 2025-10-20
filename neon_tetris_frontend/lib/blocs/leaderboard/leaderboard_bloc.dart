import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/leaderboard/leaderboard_event.dart';
import 'package:neon_tetris_frontend/blocs/leaderboard/leaderboard_state.dart';
import 'package:neon_tetris_frontend/services/user_service.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  LeaderboardBloc() : super(LeaderboardInitial()) {
    on<LeaderboardFetched>(_onLeaderboardFetched);
  }

  Future<void> _onLeaderboardFetched(
    LeaderboardFetched event,
    Emitter<LeaderboardState> emit,
  ) async {
    emit(LeaderboardLoading());
    try {
      final leaderboard = await UserService.getLeaderboard();
      emit(LeaderboardLoadSuccess(leaderboard));
    } catch (e) {
      emit(LeaderboardLoadFailure(e.toString()));
    }
  }
}
