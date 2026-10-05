class AuthUser {
  const AuthUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.token,
  });

  final int userId;
  final String name;
  final String email;
  final String token;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      userId: json['user_id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'token': token,
      };
}

class AuthResponse {
  const AuthResponse({
    required this.status,
    required this.message,
    this.data,
  });

  final bool status;
  final String message;
  final AuthUser? data;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? AuthUser.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
