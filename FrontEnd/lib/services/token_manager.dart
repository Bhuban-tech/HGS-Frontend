import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../route/app_routes.dart';

class TokenManager {
  static const String _accessTokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';

  /// Save tokens and user data after successful login
  Future<void> saveTokens({
    required String accessToken,
    required String userId,
    required String email,
    required String userName,
    String refreshToken = '', // optional if you have it
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, userName);

    // Optionally save refresh token if used
    if (refreshToken.isNotEmpty) {
      await prefs.setString('refresh_token', refreshToken);
    }

    try {
      final payload = Jwt.parseJwt(accessToken);
      if (kDebugMode) print('SAVE TOKEN - JWT PAYLOAD: $payload');

      final role = _extractRole(payload);
      if (kDebugMode) print('Extracted role: $role');

      if (role != null) {
        await prefs.setString(_userRoleKey, role);
        if (kDebugMode) print('Saved role: $role');
      }
    } catch (e) {
      if (kDebugMode) print('JWT decode error during save: $e');
    }
  }

  /// Get stored access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  /// Get basic user data (id, name, email, role)
  Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_userIdKey);

    if (id == null) return null;

    return {
      'id': id,
      'userName': prefs.getString(_userNameKey) ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
      'role': prefs.getString(_userRoleKey) ?? '',
    };
  }

  /// Check if user is logged in and token is valid
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;

    try {
      return !Jwt.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  /// Main redirection logic based on role
  Future<void> redirectBasedOnRole(BuildContext context) async {
    final token = await getAccessToken();

    // If no token or expired → go to login
    if (token == null || Jwt.isExpired(token)) {
      await clearAll();
      _goToLogin(context);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedUserName = prefs.getString(_userNameKey) ?? "User";

    try {
      final payload = Jwt.parseJwt(token);
      final role = _extractRole(payload);

      if (kDebugMode) {
        print('JWT Payload: $payload');
        print('Redirecting with role: $role');
        print('User name: $savedUserName');
      }

      switch (role) {
        case 'SUPERADMIN':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.adminDashboard,
                (route) => false,
          );
          break;

        case 'USER':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.userDashboard,
                (route) => false,
            arguments: savedUserName, // ← Pass the real user's name here
          );
          break;

        case 'PROVIDER':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.providerDashboard,
                (route) => false,
          );
          break;

        default:
        // Unknown role → logout
          await clearAll();
          _goToLogin(context);
      }
    } catch (e) {
      if (kDebugMode) print('Redirect error: $e');
      await clearAll();
      _goToLogin(context);
    }
  }

  /// Manual logout
  Future<void> logout(BuildContext context) async {
    await clearAll();
    _goToLogin(context);
  }

  /// Clear all stored data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Navigate to login screen
  void _goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  /// Extract role from JWT payload (supports multiple formats)
  String? _extractRole(Map<String, dynamic> payload) {
    // Direct 'role' field as string
    if (payload['role'] is String) {
      return payload['role'].toString().toUpperCase();
    }

    // 'role' as list
    if (payload['role'] is List && (payload['role'] as List).isNotEmpty) {
      return (payload['role'][0] as String).toUpperCase();
    }

    // 'roles' as list
    if (payload['roles'] is List && (payload['roles'] as List).isNotEmpty) {
      return (payload['roles'][0] as String).toUpperCase();
    }

    // Custom field like 'user_role', 'type', etc. (add if needed)
    // Example: if (payload['type'] != null) return payload['type'].toString().toUpperCase();

    return null;
  }
}