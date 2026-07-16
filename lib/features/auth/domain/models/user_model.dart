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

  factory UserModel.fromLoginResponse(Map<String, dynamic> json) {
    final data = _asMap(json['data']) ?? json;
    final user = _asMap(data['user']) ?? _asMap(json['user']) ?? data;
    final token =
        _readString(data['token']) ??
        _readString(json['token']) ??
        _readString(data['accessToken']) ??
        _readString(json['accessToken']);
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
      grade: _readString(user['grade']),
      token: token,
      imageUrl: _readString(user['image']),
      phone:
          _readString(user['phone']) ??
          _readString(user['phoneNumber']) ??
          _readString(json['phone']),
      address: _readString(user['address']) ?? _readString(json['address']),
      roles: _readStringList(user['roles']),
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

  static List<String> _readStringList(Object? value) {
    if (value is! List) return const [];
    return value.map((item) => item.toString()).toList(growable: false);
  }
}
