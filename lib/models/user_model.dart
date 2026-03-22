class User {
  final String? userId;
  final String username;
  final String email;
  final String? image;
  final int phone;
  final String role;
  final DateTime? lastLogin;

  User({
    this.userId,
    this.image,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      image: json['image'] as String,
      userId: json['user_id'] as String,
      username: json['name'] as String,
      email: json['email'] as String,
      phone: int.tryParse(json['phone']?.toString() ?? '0') ?? 0,
      role: json['role'] as String,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': username,
      'email': email,
      'phone': phone,
      'role': role,
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
    };
  }

  // CopyWith method for immutable updates
  User copyWith({
    String? userId,
    String? username,
    String? email,
    int? phone,
    String? role,
    DateTime? lastLogin,
  }) {
    return User(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
