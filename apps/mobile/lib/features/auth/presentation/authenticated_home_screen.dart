import 'package:flutter/material.dart';

import '../application/auth_controller.dart';

class AuthenticatedHomeScreen extends StatelessWidget {
  const AuthenticatedHomeScreen({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    final user = controller.user!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('RideTogether'),
        actions: [
          IconButton(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout),
              tooltip: 'Log out')
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined, size: 72),
              const SizedBox(height: 16),
              Text('Welcome, ${user.name}',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(user.email),
              const SizedBox(height: 24),
              const Text(
                  'Your account is ready. Trip coordination will arrive in a future phase.'),
            ],
          ),
        ),
      ),
    );
  }
}
