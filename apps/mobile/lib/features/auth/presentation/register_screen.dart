import 'package:flutter/material.dart';

import '../application/auth_controller.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create your RideTogether account')),
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
                  Text('Create an account',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _name,
                    autofillHints: const [AutofillHints.name],
                    decoration:
                        const InputDecoration(labelText: 'Display name'),
                    validator: (value) => (value?.trim().length ?? 0) >= 2
                        ? null
                        : 'Enter at least 2 characters.',
                  ),
                  const SizedBox(height: 12),
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
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: _registrationPasswordValidator,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                      'Use at least 12 characters, including a letter and a number.'),
                  const SizedBox(height: 24),
                  FilledButton(
                      onPressed: _register,
                      child: const Text('Create account')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.controller.register(
      name: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    );
    if (mounted && widget.controller.status == AuthStatus.authenticated) {
      Navigator.of(context).pop();
    }
  }
}

String? _registrationPasswordValidator(String? value) {
  final password = value ?? '';
  if (password.length < 12 ||
      !RegExp('[A-Za-z]').hasMatch(password) ||
      !RegExp('[0-9]').hasMatch(password)) {
    return 'Use at least 12 characters, including a letter and a number.';
  }
  return null;
}
