import 'package:flutter/material.dart';

import '../features/home/presentation/home_screen.dart';

abstract final class AppRouter {
  static Route<void> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const HomeScreen(),
    );
  }
}
