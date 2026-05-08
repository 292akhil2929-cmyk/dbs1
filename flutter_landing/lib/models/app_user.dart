class AppUser {
  final int userId;
  final String fullName;
  final String email;
  final String token;
  final String role;

  const AppUser({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.token,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        userId: (j['user_id'] as num?)?.toInt() ?? 0,
        fullName: j['full_name'] as String? ?? j['name'] as String? ?? 'User',
        email: j['email'] as String? ?? '',
        token: j['token'] as String? ?? '',
        role: j['role'] as String? ?? 'customer',
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'full_name': fullName,
        'email': email,
        'token': token,
        'role': role,
      };
}
