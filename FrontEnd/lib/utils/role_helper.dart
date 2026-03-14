import 'package:HamroGharSewa/services/token_manager.dart';

/// Helper class to check user roles throughout the app
class RoleHelper {
  static final TokenManager _tokenManager = TokenManager();

  /// Get current user's role
  static Future<String?> getCurrentRole() async {
    final userData = await _tokenManager.getUserData();
    return userData?['role']?.toUpperCase();
  }

  /// Check if current user is an Admin/SuperAdmin
  static Future<bool> isAdmin() async {
    final role = await getCurrentRole();
    return role == 'SUPERADMIN' || role == 'ADMIN';
  }

  /// Check if current user is a Service Provider
  static Future<bool> isProvider() async {
    final role = await getCurrentRole();
    return role == 'PROVIDER' || role == 'SERVICE_PROVIDER';
  }

  /// Check if current user is a regular User
  static Future<bool> isUser() async {
    final role = await getCurrentRole();
    return role == 'USER';
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final userData = await _tokenManager.getUserData();
    return userData?['id'];
  }

  /// Get user name
  static Future<String?> getUserName() async {
    final userData = await _tokenManager.getUserData();
    return userData?['userName'];
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    final userData = await _tokenManager.getUserData();
    return userData?['email'];
  }

  /// Get all user data at once
  static Future<Map<String, String>?> getUserData() async {
    return await _tokenManager.getUserData();
  }

  /// Check if user has specific role
  static Future<bool> hasRole(String role) async {
    final currentRole = await getCurrentRole();
    return currentRole == role.toUpperCase();
  }

  /// Get role display name (for UI)
  static String getRoleDisplayName(String? role) {
    if (role == null) return 'Unknown';
    
    switch (role.toUpperCase()) {
      case 'SUPERADMIN':
        return 'Super Admin';
      case 'ADMIN':
        return 'Admin';
      case 'SERVICE_PROVIDER':
      case 'PROVIDER':
        return 'Service Provider';
      case 'USER':
        return 'User';
      default:
        return role;
    }
  }
}
