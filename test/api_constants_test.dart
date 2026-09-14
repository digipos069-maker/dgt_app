import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dgt_app/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('defines production and local baseUrl constants', () {
      expect(ApiConstants.productionBaseUrl, 'https://api.digital-teachers.com');
      expect(ApiConstants.localBaseUrl, 'http://192.168.56.1:3002');
    });

    test('resolves baseUrl correctly based on environment / debug mode', () {
      if (kDebugMode) {
        expect(ApiConstants.baseUrl, ApiConstants.localBaseUrl);
      } else {
        expect(ApiConstants.baseUrl, ApiConstants.productionBaseUrl);
      }
    });

    test('all endpoints are prefixed with /api', () {
      expect(ApiConstants.loginPath, startsWith('/api'));
      expect(ApiConstants.registerPath, startsWith('/api'));
      expect(ApiConstants.currentUserPath, startsWith('/api'));
      expect(ApiConstants.gradesPath, startsWith('/api'));
      expect(ApiConstants.lessonsPath, startsWith('/api'));
    });
  });
}
