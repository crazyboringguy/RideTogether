import 'package:flutter/material.dart';

import '../routing/app_router.dart';

class RideTogetherApp extends StatelessWidget {
  const RideTogetherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RideTogether',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
