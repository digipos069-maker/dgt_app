import 'profile_models.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.grade,
    this.token,
    this.imageUrl,
    this.phone,
    this.address,
    this.roles = const [],
    this.subscriptions = const [],
    this.paymentHistory = const [],
  });

  final String id;
  final String email;
  final String username;
  final String? grade;
  final String? token;
  final String? imageUrl;
  final String? phone;
  final String? address;
  final List<String> roles;
  final List<SubscriptionModel> subscriptions;
  final List<PaymentHistoryModel> paymentHistory;

  Map<String, dynamic> toStoredSessionJson() {
    return {
      'accessToken': token,
      'user': {
        'id': id,
        'email': email,
        'name': username,
        'grade': grade,
        'image': imageUrl,
        'phone': phone,
        'address': address,
        'roles': roles,
      },
    };
  }

  factory UserModel.fromLoginResponse(
    Map<String, dynamic> json, {
    String? fallbackToken,
  }) {
    final data = _asMap(json['data']) ?? json;
    final user = _asMap(data['user']) ?? _asMap(json['user']) ?? data;
    final token =
        _readString(data['token']) ??
        _readString(json['token']) ??
        _readString(data['accessToken']) ??
        _readString(json['accessToken']) ??
        fallbackToken;
    final email =
        _readString(user['email']) ?? _readString(json['email']) ?? '';
    final username =
        _readString(user['username']) ??
        _readString(user['fullName']) ??
        _readString(user['name']) ??
        (email.contains('@') ? email.split('@').first : 'User');

    return UserModel(
      id:
          _readString(user['id']) ??
          _readString(user['_id']) ??
          _readString(json['id']) ??
          email,
      email: email,
      username: username,
      grade: _readString(user['grade']) ?? _readString(user['gradeId']),
      token: token,
      imageUrl:
          _readString(user['profileImageUrl']) ?? _readString(user['image']),
      phone:
          _readString(user['phone']) ??
          _readString(user['phoneNumber']) ??
          _readString(json['phone']),
      address: _readString(user['address']) ?? _readString(json['address']),
      roles: _readRoles(user['roles']),
      subscriptions: _readMapList(
        user['subscriptions'],
      ).map(SubscriptionModel.fromJson).toList(growable: false),
      paymentHistory: _readMapList(
        user['paymentHistory'],
      ).map(PaymentHistoryModel.fromJson).toList(growable: false),
    );
  }

  static Map<String, dynamic>? _asMap(Object? value) {
    return value is Map<String, dynamic> ? value : null;
  }

  static String? _readString(Object? value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static List<String> _readRoles(Object? value) {
    if (value is! List) return const [];
    return value
        .map((item) {
          if (item is Map<String, dynamic>) {
            final role = _asMap(item['role']);
            return _readString(role?['code']) ??
                _readString(role?['name']) ??
                _readString(item['code']) ??
                '';
          }
          return item.toString();
        })
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static List<Map<String, dynamic>> _readMapList(Object? value) {
    if (value is! List) return const [];
    return value.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}
