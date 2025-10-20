import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final String email;
  final String username;
  final String password;
  final String otp;

  const RegisterSubmitted({
    required this.email,
    required this.username,
    required this.password,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, username, password, otp];
}