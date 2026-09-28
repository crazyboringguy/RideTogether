import 'package:flutter/material.dart';

import '../application/auth_controller.dart';
import 'authenticated_home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.controller});

  final AuthController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => switch (controller.status) {
        AuthStatus.initializing || AuthStatus.authenticating => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        AuthStatus.authenticated =>
          AuthenticatedHomeScreen(controller: controller),
        AuthStatus.unauthenticated ||
        AuthStatus.error =>
          LoginScreen(controller: controller),
      },
    );
  }
}
