class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    this.grade,
  });

  final String id;
  final String email;
  final String username;
  final String? grade;
}
