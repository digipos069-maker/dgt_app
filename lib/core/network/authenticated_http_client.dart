import 'package:http/http.dart' as http;

/// Called when a request sent with [token] was rejected with HTTP 401.
typedef UnauthorizedCallback = void Function(String token);

/// Shared HTTP client used by every API service.
///
/// It forwards requests to [inner] unchanged and watches the responses: when a
/// request that carried a `Bearer` token comes back with 401, [onUnauthorized]
/// is called with that token so the app can end the session. Requests without
/// a token (login, register, public endpoints) are never treated as a session
/// failure, and 403 is left to the caller because the API also uses it for
/// access rules such as subscription limits.
class AuthenticatedHttpClient extends http.BaseClient {
  AuthenticatedHttpClient({
    required http.Client inner,
    required UnauthorizedCallback onUnauthorized,
  }) : _inner = inner,
       _onUnauthorized = onUnauthorized;

  final http.Client _inner;
  final UnauthorizedCallback _onUnauthorized;

  static const _bearerPrefix = 'Bearer ';

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final token = _bearerToken(request);
    final response = await _inner.send(request);

    if (response.statusCode == 401 && token != null) {
      _onUnauthorized(token);
    }
    return response;
  }

  String? _bearerToken(http.BaseRequest request) {
    // package:http stores header names case-insensitively.
    final header = request.headers['Authorization'];
    if (header == null || !header.startsWith(_bearerPrefix)) return null;

    final token = header.substring(_bearerPrefix.length).trim();
    return token.isEmpty ? null : token;
  }

  @override
  void close() => _inner.close();
}
