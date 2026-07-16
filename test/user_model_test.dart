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
}
