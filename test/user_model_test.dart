import 'package:dgt_app/features/auth/domain/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses optional profile fields from login response', () {
    final user = UserModel.fromLoginResponse({
      'accessToken': 'token',
      'user': {
        'id': 8,
        'name': 'Student One',
        'email': 'student@example.com',
        'phoneNumber': '012 345 678',
        'address': 'Phnom Penh',
        'roles': ['student'],
      },
    });

    expect(user.username, 'Student One');
    expect(user.phone, '012 345 678');
    expect(user.address, 'Phnom Penh');
  });

  test(
    'parses subscription and payment history from current user response',
    () {
      final user = UserModel.fromLoginResponse({
        'success': true,
        'user': {
          'id': 8,
          'name': 'Student One',
          'email': 'student@example.com',
          'gradeId': 11,
          'roles': [
            {
              'role': {'code': 'student', 'name': 'Student'},
            },
          ],
          'subscriptions': [
            {
              'id': 10,
              'status': 'pending',
              'endAt': '2026-08-12T08:04:51.721Z',
              'plan': {
                'id': 2,
                'name': 'Premium',
                'price': 10,
                'currency': 'USD',
                'isActive': true,
              },
            },
          ],
          'paymentHistory': [
            {
              'id': 3,
              'trxId': 'BT-123',
              'paymentType': 'bank_transfer',
              'paymentUsername': 'KHR',
              'amount': 12000,
              'status': 'success',
              'createdAt': '2026-07-09T08:27:14.882Z',
            },
          ],
        },
      }, fallbackToken: 'existing-token');

      expect(user.token, 'existing-token');
      expect(user.grade, '11');
      expect(user.roles, ['student']);
      expect(user.subscriptions.single.plan.name, 'Premium');
      expect(user.paymentHistory.single.amount, 12000);
      expect(user.paymentHistory.single.status, 'success');
    },
  );
}
