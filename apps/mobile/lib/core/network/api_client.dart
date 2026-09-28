import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(this.message, this.statusCode);

  final String message;
  final int statusCode;
}

class ApiClient {
  ApiClient({required String baseUrl, http.Client? client})
      : _baseUri = Uri.parse(baseUrl),
        _client = client ?? http.Client();

  final Uri _baseUri;
  final http.Client _client;

  Future<Map<String, dynamic>> get(String path, {String? token}) =>
      _send('GET', path, token: token);

  Future<Map<String, dynamic>> post(String path,
          {Map<String, dynamic>? body, String? token}) =>
      _send('POST', path, body: body, token: token);

  Future<void> postWithoutBody(String path, {String? token}) async {
    await _send('POST', path, token: token, expectsBody: false);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? token,
    bool expectsBody = true,
  }) async {
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (token != null) headers['Authorization'] = 'Bearer $token';

    final request = http.Request(method, _baseUri.resolve(path))
      ..headers.addAll(headers)
      ..body = body == null ? '' : jsonEncode(body);
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(decoded['error'] as String? ?? 'Request failed.',
          response.statusCode);
    }
    if (!expectsBody) return <String, dynamic>{};
    return decoded;
  }
}
