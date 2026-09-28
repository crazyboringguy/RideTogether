import 'package:flutter/foundation.dart';

import '../../../core/configuration/api_configuration.dart';
import '../../../core/network/api_client.dart';
import '../data/auth_api.dart';
import '../data/auth_session_store.dart';
import '../domain/user.dart';

enum AuthStatus {
  initializing,
  unauthenticated,
  authenticating,
  authenticated,
  error
}

class AuthController extends ChangeNotifier {
  AuthController({required AuthApi api, required AuthSessionStore sessionStore})
      : _api = api,
        _sessionStore = sessionStore;

  factory AuthController.production() => AuthController(
        api: RestAuthApi(ApiClient(baseUrl: ApiConfiguration.baseUrl)),
        sessionStore: SecureAuthSessionStore(),
      );

  final AuthApi _api;
  final AuthSessionStore _sessionStore;

  AuthStatus _status = AuthStatus.initializing;
  AuthStatus get status => _status;
  User? _user;
  User? get user => _user;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  String? _token;

  Future<void> initialize() async {
    final token = await _sessionStore.readToken();
    if (token == null) return _setUnauthenticated();
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      _token = token;
      _user = await _api.currentUser(token);
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (_) {
      await _sessionStore.clearToken();
      _setUnauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) =>
      _authenticate(() => _api.login(email: email, password: password));

  Future<void> register(
          {required String name,
          required String email,
          required String password}) =>
      _authenticate(
          () => _api.register(name: name, email: email, password: password));

  Future<void> logout() async {
    final token = _token;
    if (token != null) {
      try {
        await _api.logout(token);
      } catch (_) {
        // Clearing a local credential still protects this device if the network is unavailable.
      }
    }
    await _sessionStore.clearToken();
    _setUnauthenticated();
  }

  Future<void> _authenticate(Future<AuthResponse> Function() operation) async {
    _status = AuthStatus.authenticating;
    _errorMessage = null;
    notifyListeners();
    try {
      final result = await operation();
      _token = result.token;
      _user = result.user;
      await _sessionStore.writeToken(result.token);
      _status = AuthStatus.authenticated;
    } on ApiException catch (error) {
      _status = AuthStatus.error;
      _errorMessage = error.message;
    } catch (_) {
      _status = AuthStatus.error;
      _errorMessage = 'Unable to connect. Please try again.';
    }
    notifyListeners();
  }

  void _setUnauthenticated() {
    _token = null;
    _user = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
