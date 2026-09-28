import '../../../core/network/api_client.dart';
import '../domain/user.dart';

class AuthResponse {
  const AuthResponse({required this.user, required this.token});

  final User user;
  final String token;
}

abstract interface class AuthApi {
  Future<AuthResponse> register(
      {required String name, required String email, required String password});
  Future<AuthResponse> login({required String email, required String password});
  Future<User> currentUser(String token);
  Future<void> logout(String token);
}

class RestAuthApi implements AuthApi {
  RestAuthApi(this._client);

  final ApiClient _client;

  @override
  Future<AuthResponse> register(
          {required String name,
          required String email,
          required String password}) =>
      _authenticate('/auth/register',
          {'name': name, 'email': email, 'password': password});

  @override
  Future<AuthResponse> login(
          {required String email, required String password}) =>
      _authenticate('/auth/login', {'email': email, 'password': password});

  @override
  Future<User> currentUser(String token) async {
    final result = await _client.get('/auth/me', token: token);
    return User.fromJson(result['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout(String token) =>
      _client.postWithoutBody('/auth/logout', token: token);

  Future<AuthResponse> _authenticate(
      String path, Map<String, dynamic> body) async {
    final result = await _client.post(path, body: body);
    return AuthResponse(
      user: User.fromJson(result['user'] as Map<String, dynamic>),
      token: result['token'] as String,
    );
  }
}
