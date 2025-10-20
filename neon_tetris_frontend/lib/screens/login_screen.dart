import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_bloc.dart';
import 'package:neon_tetris_frontend/blocs/auth/auth_event.dart';
import 'package:neon_tetris_frontend/blocs/login/login_bloc.dart';
import 'package:neon_tetris_frontend/blocs/login/login_event.dart';
import 'package:neon_tetris_frontend/blocs/login/login_state.dart';
import 'package:neon_tetris_frontend/screens/verify_email_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both email and password'),
          backgroundColor: Color.fromARGB(255, 228, 31, 67),
        ),
      );
      return;
    }
    context.read<LoginBloc>().add(
      LoginSubmitted(email: email, password: password),
    );
  }

  void _navigateToRegister() {
    Future.microtask(() {
      Navigator.push(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()),
      );
    });
  }

  void _forgotPassword() {}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              } else if (state is LoginSuccess) {
                context.read<AuthBloc>().add(LoggedIn());
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome Back !',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Login to your account',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 32),

                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: "xxxxx@gmail.com",
                              labelText: "E-mail",
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),

                          TextField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              hintText: "password",
                              labelText: "Password",
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _forgotPassword,
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          BlocBuilder<LoginBloc, LoginState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: () {
                                  if (state is LoginLoading) {
                                    null;
                                  } else {
                                    FocusScope.of(context).unfocus();
                                    _login();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 60,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: state is LoginLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        '  Login  ',
                                        style: TextStyle(fontSize: 16),
                                      ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          ElevatedButton(
                            onPressed: _navigateToRegister,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              'New? Register',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
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
