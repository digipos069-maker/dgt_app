import 'dart:convert';

import 'package:dgt_app/core/utils/app_exception.dart';
import 'package:dgt_app/features/subscription/data/subscription_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  group('SubscriptionApiService', () {
    test('uploadPayslip sends multipart request and returns uploaded url',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/payment/upload-payslip');
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer mock-token');

        return http.Response(
          jsonEncode({
            'url': '/uploads/payslip-1741521234567-891234567.jpg',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = SubscriptionApiService(client: mockClient);
      final url = await service.uploadPayslip(
        fileBytes: [1, 2, 3],
        filename: 'receipt.png',
        token: 'mock-token',
      );

      expect(url, '/uploads/payslip-1741521234567-891234567.jpg');
    });

    test('uploadPayslip throws AppException on 400 Bad Request', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'statusCode': 400,
            'message': 'No file uploaded',
            'error': 'Bad Request',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = SubscriptionApiService(client: mockClient);

      expect(
        () => service.uploadPayslip(
          fileBytes: [],
          filename: 'empty.png',
          token: 'mock-token',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'No file uploaded',
          ),
        ),
      );
    });

    test('submitBankTransfer sends payment data and returns message and trxId',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/payment/bank-transfer');
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer mock-token');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['planId'], 2);
        expect(body['amount'], 12000);
        expect(body['currency'], 'khr');
        expect(body['billingCycle'], 'monthly');
        expect(body['payslipUrl'],
            '/uploads/payslip-1741521234567-891234567.jpg');

        return http.Response(
          jsonEncode({
            'message': 'Bank transfer submitted and is pending verification',
            'trxId': 'BT-1741521345678-4321',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = SubscriptionApiService(client: mockClient);
      final result = await service.submitBankTransfer(
        planId: 2,
        amount: 12000,
        currency: 'khr',
        billingCycle: 'monthly',
        payslipUrl: '/uploads/payslip-1741521234567-891234567.jpg',
        token: 'mock-token',
      );

      expect(result['message'],
          'Bank transfer submitted and is pending verification');
      expect(result['trxId'], 'BT-1741521345678-4321');
    });

    test('submitBankTransfer throws AppException on 404 Plan not found',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'statusCode': 404,
            'message': 'Plan not found',
            'error': 'Not Found',
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = SubscriptionApiService(client: mockClient);

      expect(
        () => service.submitBankTransfer(
          planId: 999,
          amount: 12000,
          currency: 'khr',
          billingCycle: 'monthly',
          payslipUrl: '/uploads/payslip.jpg',
          token: 'mock-token',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            'Plan not found',
          ),
        ),
      );
    });

    test('upgradeSubscription sends newPlanId and returns subscription record',
        () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/upgrade-subscription');
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer mock-token');

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['newPlanId'], 2);

        return http.Response(
          jsonEncode({
            'id': 15,
            'userId': 42,
            'planId': 2,
            'status': 'pending',
            'subAccountLimit': 1,
            'startAt': '2026-09-09T12:50:00.000Z',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = SubscriptionApiService(client: mockClient);
      final result = await service.upgradeSubscription(
        newPlanId: 2,
        token: 'mock-token',
      );

      expect(result['id'], 15);
      expect(result['planId'], 2);
      expect(result['status'], 'pending');
    });

    test('upgradeSubscription handles 400 Bad Request error array message',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'statusCode': 400,
            'message': [
              'newPlanId must not be less than 1',
              'newPlanId must be an integer number',
            ],
            'error': 'Bad Request',
          }),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = SubscriptionApiService(client: mockClient);

      expect(
        () => service.upgradeSubscription(
          newPlanId: 0,
          token: 'mock-token',
        ),
        throwsA(
          isA<AppException>().having(
            (e) => e.message,
            'message',
            contains('newPlanId must not be less than 1'),
          ),
        ),
      );
    });
  });
}
