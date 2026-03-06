class AuthResponse {
  final bool success;
  final String message;           // Always has a value
  final String? accessToken;
  final UserData? user;

  AuthResponse({
    required this.success,
    required this.message,
    this.accessToken,
    this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Extract 'data' safely
    final Map<String, dynamic>? data = json['data'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(json['data'])
        : null;

    // Get raw message or fallback
    final String rawMessage = (json['message'] as String?)?.trim() ?? '';

    // Smart fallback based on success status
    final String message = rawMessage.isNotEmpty
        ? rawMessage
        : (json['success'] == true
            ? 'Operation completed successfully'
            : 'Something went wrong. Please try again.');

    return AuthResponse(
      success: json['success'] == true,
      message: message,
      accessToken: (data?['token'] ?? data?['accessToken'])?.toString(),
      user: data != null && (data.containsKey('id') || data.containsKey('user'))
          ? UserData.fromJson(data['user'] ?? data)
          : null,
    );
  }

  get data => null;

  @override
  String toString() {
    return 'AuthResponse(success: $success, message: "$message", '
        'accessToken: ${accessToken != null}, user: ${user != null})';
  }
}

class UserData {
  final String id;
  final String userName;
  final String email;
  final String role;

  UserData({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      userName: json['userName']?.toString() ?? 'User',
      email: json['email']?.toString() ?? '',
      role: (json['role']?.toString() ?? 'USER').toUpperCase(),
    );
  }

  @override
  String toString() {
    return 'UserData(id: $id, name: $userName, email: $email, role: $role)';
  }
}