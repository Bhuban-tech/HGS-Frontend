import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:HamroGharSewa/constants/api_constants.dart'; // Import your ApiConstants
import 'package:HamroGharSewa/services/token_manager.dart'; // If you have token management

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Helper to get headers (with optional auth)
  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final token = requireAuth ? await TokenManager().getAccessToken() : null;

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ------------------- AUTH METHODS -------------------

  /// Registers a new user
  Future<Map<String, dynamic>> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: await _getHeaders(requireAuth: false),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Registration failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// Example: Login (add your actual response structure)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: await _getHeaders(requireAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Save tokens (adjust keys based on your backend response)
      await TokenManager().saveTokens(
        accessToken: data['accessToken'] ?? data['token'],
        refreshToken: data['refreshToken'], userId: '', email: '', userName: '',
      );
      return data;
    } else {
      throw Exception('Login failed: ${response.statusCode} - ${response.body}');
    }
  }

  // ------------------- ADMIN METHODS (SUPERADMIN only) -------------------

  /// Get all users (admin only)
  Future<List<dynamic>> getAllUsers() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminUsers),
      headers: await _getHeaders(),
    );

    return _handleApiResponse(response);
  }

  /// Get all service providers
  Future<List<dynamic>> getAllProviders() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminProviders),
      headers: await _getHeaders(),
    );

    return _handleApiResponse(response);
  }

  /// Get pending providers
  Future<List<dynamic>> getPendingProviders() async {
    final response = await http.get(
      Uri.parse(ApiConstants.adminPendingProviders),
      headers: await _getHeaders(),
    );

    return _handleApiResponse(response);
  }

  /// Approve a provider
  Future<void> approveProvider(String id) async {
    final response = await http.patch(
      Uri.parse(ApiConstants.adminApproveProvider(id)),
      headers: await _getHeaders(),
      body: jsonEncode({}), // empty body if no data needed
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to approve provider: ${response.body}');
    }
  }

  /// Reject a provider
  Future<void> rejectProvider(String id) async {
    final response = await http.patch(
      Uri.parse(ApiConstants.adminRejectProvider(id)),
      headers: await _getHeaders(),
      body: jsonEncode({}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to reject provider: ${response.body}');
    }
  }

  // ------------------- HELPER METHODS -------------------

  List<dynamic> _handleApiResponse(http.Response response) {
    if (response.statusCode == 200) {
      final apiResponse = jsonDecode(response.body);
      if (apiResponse['success'] == true) {
        return apiResponse['data'] as List<dynamic>;
      } else {
        throw Exception(apiResponse['message'] ?? 'API returned failure');
      }
    } else {
      throw Exception(
        'API request failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

 // Add these methods to your existing ApiService class

// ------------------- CATEGORY METHODS -------------------

/// Get all active categories (public endpoint)
Future<List<dynamic>> getAllActiveCategories() async {
  final response = await http.get(
    Uri.parse(ApiConstants.categories),
    headers: await _getHeaders(requireAuth: false), // Public endpoint
  );

  return _handleApiResponse(response);
}

/// Create a category (admin only)
Future<Map<String, dynamic>> createCategory({
  required String name,
  required String description,
  required String icon,
}) async {
  final response = await http.post(
    Uri.parse(ApiConstants.categories),
    headers: await _getHeaders(),
    body: jsonEncode({
      'name': name,
      'description': description,
      'icon': icon,
    }),
  );

  if (response.statusCode == 200) {
    final apiResponse = jsonDecode(response.body);
    if (apiResponse['success'] == true) {
      return apiResponse['data'];
    } else {
      throw Exception(apiResponse['message'] ?? 'Failed to create category');
    }
  } else {
    throw Exception(
      'Failed to create category: ${response.statusCode} - ${response.body}',
    );
  }
}

/// Update a category (admin only)
Future<Map<String, dynamic>> updateCategory({
  required String id,
  required String name,
  required String description,
  required String icon,
}) async {
  final response = await http.put(
    Uri.parse(ApiConstants.categoryById(id)),
    headers: await _getHeaders(),
    body: jsonEncode({
      'name': name,
      'description': description,
      'icon': icon,
    }),
  );

  if (response.statusCode == 200) {
    final apiResponse = jsonDecode(response.body);
    if (apiResponse['success'] == true) {
      return apiResponse['data'];
    } else {
      throw Exception(apiResponse['message'] ?? 'Failed to update category');
    }
  } else {
    throw Exception(
      'Failed to update category: ${response.statusCode} - ${response.body}',
    );
  }
}

/// Delete a category (admin only - soft delete)
Future<void> deleteCategory(String id) async {
  final response = await http.delete(
    Uri.parse(ApiConstants.categoryById(id)),
    headers: await _getHeaders(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete category: ${response.body}');
  }
}
}