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


  Future<void> saveTokens({
    required String accessToken,
    required String userId,
    required String email,
    required String userName, required refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_userEmailKey, email);
    await prefs.setString(_userNameKey, userName);

    try {
      final payload = Jwt.parseJwt(accessToken);
       print('SAVE TOKEN - JWT PAYLOAD: $payload');
      final role = _extractRole(payload);
       print('role: $role');

      if (role != null) {
        await prefs.setString(_userRoleKey, role);
        if (kDebugMode) print('Saved role: $role');
      }
    } catch (e) {
      if (kDebugMode) print('JWT decode error: $e');
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }


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


  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) return false;

    try {
      return !Jwt.isExpired(token);
    } catch (_) {
      return false;
    }
  }

  Future<void> redirectBasedOnRole(BuildContext context) async {
    final token = await getAccessToken();

    if (token == null || Jwt.isExpired(token)) {
      await clearAll();
      _goToLogin(context);
      return;
    }

    try {
      final payload = Jwt.parseJwt(token);
      final role = _extractRole(payload);

      if (kDebugMode) {
        print('JWT Payload: $payload');
        print('Redirecting with role: $role');
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
          );
          break;

        case 'PROVIDER':
        case 'SERVICE_PROVIDER':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.providerDashboard,
            (route) => false,
          );
          break;

        case 'PROVIDER':
        case 'SERVICE_PROVIDER':
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.providerDashboard,
            (route) => false,
          );
          break;

        default:
          await clearAll();
          _goToLogin(context);
      }
    } catch (e) {
      if (kDebugMode) print('Redirect error: $e');
      await clearAll();
      _goToLogin(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    await clearAll();
    _goToLogin(context);
  }

  /// Get the correct dashboard route based on user role
  Future<String> getDashboardRoute() async {
    final userData = await getUserData();
    final role = userData?['role']?.toUpperCase() ?? '';
    
    switch (role) {
      case 'SUPERADMIN':
        return AppRoutes.adminDashboard;
      case 'SERVICE_PROVIDER':
      case 'PROVIDER':
        return AppRoutes.providerDashboard;
      case 'USER':
      default:
        return AppRoutes.userDashboard;
    }
  }

  /// ================= CLEAR STORAGE =================
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// ================= PRIVATE HELPERS =================
  void _goToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  /// Handles: role, roles, string or list
  String? _extractRole(Map<String, dynamic> payload) {
    if (payload['role'] is String) {
      return payload['role'].toString().toUpperCase();
    }

    if (payload['role'] is List && payload['role'].isNotEmpty) {
      return payload['role'][0].toString().toUpperCase();
    }

    if (payload['roles'] is List && payload['roles'].isNotEmpty) {
      return payload['roles'][0].toString().toUpperCase();
    }

    return null;
  }
}