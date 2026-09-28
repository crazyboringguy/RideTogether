import 'package:flutter/material.dart';

import '../application/auth_controller.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RideTogether')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Welcome back',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  const Text('Sign in to coordinate your group travel.'),
                  const SizedBox(height: 24),
                  if (widget.controller.errorMessage case final message?) ...[
                    Text(message,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error)),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _login,
                    child: const Text('Log in'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                          builder: (_) =>
                              RegisterScreen(controller: widget.controller)),
                    ),
                    child: const Text('Create an account'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.controller
        .login(email: _email.text.trim(), password: _password.text);
  }
}

String? emailValidator(String? value) {
  final email = value?.trim() ?? '';
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
      ? null
      : 'Enter a valid email address.';
}

String? _passwordValidator(String? value) =>
    (value?.isNotEmpty ?? false) ? null : 'Enter your password.';
