import 'package:flutter_test/flutter_test.dart';
import 'package:ride_together/core/app.dart';
import 'package:ride_together/features/auth/application/auth_controller.dart';
import 'package:ride_together/features/auth/data/auth_api.dart';
import 'package:ride_together/features/auth/data/auth_session_store.dart';
import 'package:ride_together/features/auth/domain/user.dart';

class EmptyAuthApi implements AuthApi {
  @override
  Future<User> currentUser(String token) => throw UnimplementedError();

  @override
  Future<AuthResponse> login(
          {required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthResponse> register(
          {required String name,
          required String email,
          required String password}) =>
      throw UnimplementedError();

  @override
  Future<void> logout(String token) async {}
}

class EmptySessionStore implements AuthSessionStore {
  @override
  Future<void> clearToken() async {}

  @override
  Future<String?> readToken() async => null;

  @override
  Future<void> writeToken(String token) async {}
}

void main() {
  testWidgets('shows the RideTogether authentication shell', (tester) async {
    final controller =
        AuthController(api: EmptyAuthApi(), sessionStore: EmptySessionStore());
    await tester.pumpWidget(RideTogetherApp(authController: controller));
    await tester.pump();

    expect(find.text('RideTogether'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
