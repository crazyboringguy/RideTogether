import 'package:flutter_test/flutter_test.dart';
import 'package:ride_together/features/auth/application/auth_controller.dart';
import 'package:ride_together/features/auth/data/auth_api.dart';
import 'package:ride_together/features/auth/data/auth_session_store.dart';
import 'package:ride_together/features/auth/domain/user.dart';
import 'package:ride_together/features/auth/presentation/login_screen.dart';

import 'test_app.dart';

class FakeAuthApi implements AuthApi {
  bool loggedOut = false;
  final user = User(
      id: 'user-1',
      name: 'Asha Rider',
      email: 'asha@example.com',
      createdAt: DateTime(2026));

  @override
  Future<User> currentUser(String token) async => user;

  @override
  Future<AuthResponse> login(
          {required String email, required String password}) async =>
      AuthResponse(user: user, token: 'token');

  @override
  Future<AuthResponse> register(
          {required String name,
          required String email,
          required String password}) async =>
      AuthResponse(user: user, token: 'token');

  @override
  Future<void> logout(String token) async => loggedOut = true;
}

class FakeSessionStore implements AuthSessionStore {
  String? token;

  @override
  Future<void> clearToken() async => token = null;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String value) async => token = value;
}

void main() {
  testWidgets('login and registration screens render', (tester) async {
    final controller =
        AuthController(api: FakeAuthApi(), sessionStore: FakeSessionStore());
    await tester
        .pumpWidget(TestApp(child: LoginScreen(controller: controller)));
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);

    await tester.tap(find.text('Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Display name'), findsOneWidget);
  });

  test(
      'authentication controller stores a session and transitions through logout',
      () async {
    final api = FakeAuthApi();
    final store = FakeSessionStore();
    final controller = AuthController(api: api, sessionStore: store);

    await controller.login(
        email: 'asha@example.com', password: 'safe-password-123');
    expect(controller.status, AuthStatus.authenticated);
    expect(store.token, 'token');
    expect(controller.user?.email, 'asha@example.com');

    await controller.logout();
    expect(api.loggedOut, isTrue);
    expect(store.token, isNull);
    expect(controller.status, AuthStatus.unauthenticated);
  });
}
