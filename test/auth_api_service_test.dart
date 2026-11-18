import 'dart:async';
import 'dart:convert';

import 'package:dgt_app/core/utils/app_exception.dart';
import 'package:dgt_app/features/auth/data/auth_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  for (final identifier in ['student@example.com', '012345678']) {
    test('sends the correct identifier field for $identifier', () async {
      final service = AuthApiService(
        client: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/auth/login');
          expect(jsonDecode(request.body), {
            if (identifier.contains('@'))
              'email': identifier
            else
              'phone': identifier,
            'password': ' password ',
          });
          return http.Response('{"success":true,"accessToken":"token"}', 200);
        }),
      );

      final response = await service.login(
        email: identifier,
        password: ' password ',
      );
      expect(response['accessToken'], 'token');
    });
  }

  test(
    'reports an HTML access denial instead of a JSON parsing error',
    () async {
      final service = AuthApiService(
        client: MockClient(
          (_) async =>
              http.Response('<html>Sorry, you have been blocked</html>', 403),
        ),
      );
      await expectLater(
        service.login(email: 'a@example.com', password: 'password'),
        throwsA(
          isA<AppException>()
              .having((e) => e.statusCode, 'status', 403)
              .having((e) => e.message, 'message', contains('denied')),
        ),
      );
    },
  );

  for (final body in ['', '<html>Gateway error</html>', '[]']) {
    test('rejects an invalid successful response: $body', () async {
      final service = AuthApiService(
        client: MockClient((_) async => http.Response(body, 200)),
      );
      await expectLater(
        service.login(email: 'a@example.com', password: 'password'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('invalid response'),
          ),
        ),
      );
    });
  }

  test('preserves the API error message and status', () async {
    final service = AuthApiService(
      client: MockClient(
        (_) async => http.Response('{"message":"Account is inactive"}', 403),
      ),
    );
    await expectLater(
      service.login(email: 'a@example.com', password: 'password'),
      throwsA(
        isA<AppException>()
            .having((e) => e.statusCode, 'status', 403)
            .having((e) => e.message, 'message', 'Account is inactive'),
      ),
    );
  });

  test('rejects a logical failure with HTTP 200', () async {
    final service = AuthApiService(
      client: MockClient(
        (_) async =>
            http.Response('{"success":false,"error":"Login rejected"}', 200),
      ),
    );
    await expectLater(
      service.login(email: 'a@example.com', password: 'password'),
      throwsA(
        isA<AppException>().having(
          (e) => e.message,
          'message',
          'Login rejected',
        ),
      ),
    );
  });

  for (final failure in [
    http.ClientException('network error'),
    TimeoutException('timeout'),
  ]) {
    test('converts ${failure.runtimeType} to a readable login error', () async {
      final service = AuthApiService(
        client: MockClient((_) async => throw failure),
      );
      await expectLater(
        service.login(email: 'a@example.com', password: 'password'),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains(
              failure is TimeoutException ? 'too long' : 'Cannot connect',
            ),
          ),
        ),
      );
    });
  }
}
