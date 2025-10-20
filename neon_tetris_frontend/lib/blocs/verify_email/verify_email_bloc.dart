import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'verify_email_event.dart';
import 'verify_email_state.dart';

class VerifyEmailBloc extends Bloc<VerifyEmailEvent, VerifyEmailState> {
  VerifyEmailBloc() : super(VerifyEmailInitial()) {
    on<SubmitEmail>((event, emit) async {
      emit(VerifyEmailLoading());
      try {
        await AuthService.sendOTP(event.email);
        emit(VerifyEmailSuccess());
      } catch (e) {
        String message = "Could not verify email. Try again.";
        
        // Try to extract server error message
        if (e is http.Response) {
          try {
            final data = jsonDecode(e.body);
            message = data['message'] ?? message;
          } catch (_) {}
        } else if (e is Exception) {
          final text = e.toString();
          if (text.contains('Exception: ')) {
            message = text.replaceFirst('Exception: ', '');
          }
        }

        emit(VerifyEmailFailure(message));
      }
    });
  }
}