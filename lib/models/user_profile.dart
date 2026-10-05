class UserProfile {
  const UserProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.status,
    this.createdOn,
    this.updatedOn,
  });

  final int userId;
  final String name;
  final String email;
  final int status;
  final DateTime? createdOn;
  final DateTime? updatedOn;

  bool get isActive => status == 1;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: _asInt(json['user_id']),
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      status: _asInt(json['status']),
      createdOn: _asDate(json['created_on']),
      updatedOn: _asDate(json['updated_on']),
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'email': email,
        'status': status,
        'created_on': createdOn?.toIso8601String(),
        'updated_on': updatedOn?.toIso8601String(),
      };

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse('$value') ?? 0;
  }

  static DateTime? _asDate(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}

class ProfileResponse {
  const ProfileResponse({
    required this.status,
    required this.message,
    this.data,
  });

  final bool status;
  final String message;
  final UserProfile? data;

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      status: json['status'] == true,
      message: json['message'] as String? ?? '',
      data: json['data'] is Map<String, dynamic>
          ? UserProfile.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}
