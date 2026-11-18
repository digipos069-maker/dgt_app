import 'package:dgt_app/core/network/authenticated_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  final uri = Uri.parse('https://api.example.com/api/lessons');

  AuthenticatedHttpClient clientReturning(
    int statusCode,
    List<String> rejectedTokens,
  ) {
    return AuthenticatedHttpClient(
      inner: MockClient((_) async => http.Response('{}', statusCode)),
      onUnauthorized: rejectedTokens.add,
    );
  }

  test('reports the token when an authenticated request gets 401', () async {
    final rejected = <String>[];
    final client = clientReturning(401, rejected);

    final response = await client.get(
      uri,
      headers: {'Authorization': 'Bearer abc.def.ghi'},
    );

    expect(response.statusCode, 401);
    expect(rejected, ['abc.def.ghi']);
  });

  test('reads the Authorization header case-insensitively', () async {
    final rejected = <String>[];
    final client = clientReturning(401, rejected);

    await client.get(uri, headers: {'authorization': 'Bearer token-1'});

    expect(rejected, ['token-1']);
  });

  test('ignores 401 on requests without a token, such as login', () async {
    final rejected = <String>[];
    final client = clientReturning(401, rejected);

    await client.post(uri, body: '{}');

    expect(rejected, isEmpty);
  });

  test('ignores 403 so subscription limits do not sign the user out', () async {
    final rejected = <String>[];
    final client = clientReturning(403, rejected);

    await client.get(uri, headers: {'Authorization': 'Bearer token-1'});

    expect(rejected, isEmpty);
  });

  test('ignores successful responses', () async {
    final rejected = <String>[];
    final client = clientReturning(200, rejected);

    await client.get(uri, headers: {'Authorization': 'Bearer token-1'});

    expect(rejected, isEmpty);
  });
}
