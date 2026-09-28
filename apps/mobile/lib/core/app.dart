import 'package:flutter/material.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/auth_gate.dart';

class RideTogetherApp extends StatefulWidget {
  const RideTogetherApp({super.key, this.authController});

  final AuthController? authController;

  @override
  State<RideTogetherApp> createState() => _RideTogetherAppState();
}

class _RideTogetherAppState extends State<RideTogetherApp> {
  late final AuthController _authController;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.authController == null;
    _authController = widget.authController ?? AuthController.production();
    _authController.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideTogether',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      home: AuthGate(controller: _authController),
    );
  }
}
