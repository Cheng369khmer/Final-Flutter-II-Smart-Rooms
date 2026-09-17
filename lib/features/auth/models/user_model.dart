enum UserRole { admin, staff }

class UserModel {
  final String id;
  final String username;
  final String name;
  final String email;
  final UserRole role;
  final String token;

  const UserModel({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] == 'admin' ? UserRole.admin : UserRole.staff,
      token: json['token'] ?? '',
    );
  }
}
