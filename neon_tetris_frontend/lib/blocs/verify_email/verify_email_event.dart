abstract class VerifyEmailEvent {}

class SubmitEmail extends VerifyEmailEvent {
  final String email;
  SubmitEmail({required this.email});
}