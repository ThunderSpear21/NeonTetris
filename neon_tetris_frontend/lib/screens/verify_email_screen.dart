import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/verify_email/verify_email_bloc.dart';
import 'package:neon_tetris_frontend/blocs/verify_email/verify_email_event.dart';
import 'package:neon_tetris_frontend/blocs/verify_email/verify_email_state.dart';
import 'package:neon_tetris_frontend/screens/register_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? "";
    if (email == "") {
      return "Email cannot be empty";
    }
    return null;
  }

  void _submitEmail(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    context.read<VerifyEmailBloc>().add(SubmitEmail(email: email));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Verify Email"), centerTitle: true),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocListener<VerifyEmailBloc, VerifyEmailState>(
            listener: (context, state) {
              if (state is VerifyEmailSuccess) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('OTP Sent !!')));

                Future.microtask(() {
                  Navigator.pushReplacement(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => RegisterScreen(
                            email: _emailController.text.trim(),
                          ),
                    ),
                  );
                });
              }
            },
            child: BlocBuilder<VerifyEmailBloc, VerifyEmailState>(
              builder: (context, state) {
                return Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      const Text(
                        "Enter your email",
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "e.g. xxxxx@gmail.com",
                          labelText: "Email",
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      if (state is VerifyEmailFailure)
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: state is VerifyEmailLoading
                            ? null
                            : () {
                                FocusScope.of(context).unfocus();
                                _submitEmail(context);
                              },
                        child: state is VerifyEmailLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Send OTP"),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
