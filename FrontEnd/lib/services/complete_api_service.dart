import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

/// Complete API Service integrating all backend endpoints
class CompleteApiService {
  static final CompleteApiService _instance = CompleteApiService._internal();
  factory CompleteApiService() => _instance;
  CompleteApiService._internal();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  final TokenManager _tokenManager = TokenManager();

  // ==================== 1. AUTHENTICATION ENDPOINTS ====================

  /// POST /api/auth/register - Register new user/provider and send OTP
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    String role = 'USER', // USER or SERVICE_PROVIDER
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'phoneNumber': phoneNumber,
          'role': role,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/auth/register/verify-otp - Verify OTP to complete registration
  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );
      final data = _handleResponse(response);
      
      // Save tokens after successful OTP verification
      if (data.containsKey('accessToken')) {
        await _tokenManager.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
          userId: data['userId'] ?? '',
          email: email,
          userName: data['username'] ?? '',
        );
      }
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/auth/login - Authenticate and receive JWT
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      final data = _handleResponse(response);
      
      // Save tokens
      await _tokenManager.saveTokens(
        accessToken: data['accessToken'] ?? data['token'],
        refreshToken: data['refreshToken'],
        userId: data['userId'] ?? '',
        email: email,
        userName: data['username'] ?? '',
      );
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/auth/logout - Invalidate current session
  Future<void> logout() async {
    try {
      final token = await _tokenManager.getAccessToken();
      await _dio.post(
        ApiConstants.logout,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      await _tokenManager.clearAll();
    } catch (e) {
      // Clear tokens even if API call fails
      await _tokenManager.clearAll();
      throw _handleError(e);
    }
  }

  /// POST /api/auth/refresh-token - Get new access token
  Future<Map<String, dynamic>> refreshAccessToken() async {
    try {
      // Note: Refresh token functionality needs to be added to TokenManager
      // For now, we'll skip this as it's not implemented
      throw Exception('Refresh token not implemented in TokenManager');
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 2. USER & PROFILE MANAGEMENT ====================

  /// GET /api/users/me - Fetch current user profile
  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        '/api/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/users/profile - Update profile details
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? address,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.put(
        '/api/users/profile',
        data: {
          'name': name,
          'phone': phone,
          if (address != null) 'address': address,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/users/change-password - Change password
  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.patch(
        '/api/users/change-password',
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/users/providers/category/{categoryId} - Browse providers by category
  Future<List<dynamic>> getProvidersByCategory(String categoryId) async {
    try {
      final response = await _dio.get('/api/users/providers/category/$categoryId');
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/users/forgot-password - Request password reset OTP
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email},
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/users/verify-otp - Verify reset password OTP
  Future<Map<String, dynamic>> verifyResetPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/api/users/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/users/reset-password - Set new password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 3. BOOKINGS & SERVICE REQUESTS ====================

  /// POST /api/bookings - Create new service request (USER)
  Future<Map<String, dynamic>> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingDate,
    String? description,
    String? location,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.post(
        '/api/bookings',
        data: {
          'providerId': providerId,
          'serviceId': serviceId,
          'bookingDate': bookingDate.toIso8601String(),
          if (description != null) 'description': description,
          if (location != null) 'location': location,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/bookings/my-bookings - View user's bookings (USER)
  Future<List<dynamic>> getMyBookings() async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        '/api/bookings/my-bookings',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/bookings/{id}/cancel - Cancel pending booking (USER)
  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/cancel',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/bookings/requests - View incoming requests (SERVICE_PROVIDER)
  Future<List<dynamic>> getProviderRequests() async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        '/api/bookings/requests',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/bookings/{id}/accept - Accept service request (SERVICE_PROVIDER)
  Future<Map<String, dynamic>> acceptBooking(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/accept',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/bookings/{id}/reject - Reject service request (SERVICE_PROVIDER)
  Future<Map<String, dynamic>> rejectBooking(String bookingId, String reason) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/reject',
        data: {'reason': reason},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/bookings/{id}/complete - Mark service completed
  Future<Map<String, dynamic>> completeBooking(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/complete',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/bookings/all - List all bookings (SUPERADMIN)
  Future<List<dynamic>> getAllBookings() async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        '/api/bookings/all',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 4. CHAT SYSTEM ====================

  /// POST /api/chat/send - Send message via REST (backup to WebSocket)
  Future<Map<String, dynamic>> sendChatMessage({
    required String requestId,
    required String message,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.post(
        '/api/chat/send',
        data: {
          'requestId': requestId,
          'message': message,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/chat/{requestId} - Fetch chat history
  Future<List<dynamic>> getChatHistory(String requestId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        '/api/chat/$requestId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/chat/{requestId}/unread-count - Get unread messages count
  Future<int> getUnreadMessageCount(String requestId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        '/api/chat/$requestId/unread-count',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final data = _handleResponse(response);
      return data['count'] ?? 0;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 5. SERVICE CATEGORIES ====================

  /// GET /api/categories - List all active categories (Public)
  Future<List<dynamic>> getActiveCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/categories - Create new category (SUPERADMIN)
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String description,
    required String icon,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.post(
        ApiConstants.categories,
        data: {
          'name': name,
          'description': description,
          'icon': icon,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/categories/{id} - Update category (SUPERADMIN)
  Future<Map<String, dynamic>> updateCategory({
    required String id,
    required String name,
    required String description,
    required String icon,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.put(
        ApiConstants.categoryById(id),
        data: {
          'name': name,
          'description': description,
          'icon': icon,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/categories/{id} - Delete category (SUPERADMIN)
  Future<void> deleteCategory(String id) async {
    try {
      final token = await _tokenManager.getAccessToken();
      await _dio.delete(
        ApiConstants.categoryById(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 6. ADMIN MANAGEMENT ====================

  /// GET /api/admin/users - Fetch all users
  Future<List<dynamic>> getAllUsers() async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        ApiConstants.adminUsers,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/admin/service-providers - Fetch all providers
  Future<List<dynamic>> getAllProviders() async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        ApiConstants.adminProviders,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/admin/service-providers/pending - List pending providers
  Future<List<dynamic>> getPendingProviders() async {
    try {
      final token = await _tokenManager.getAccessToken();
      final response = await _dio.get(
        ApiConstants.adminPendingProviders,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/admin/approve/{id} - Approve provider account
  Future<void> approveProvider(String id) async {
    try {
      final token = await _tokenManager.getAccessToken();
      await _dio.patch(
        ApiConstants.adminApproveProvider(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/admin/reject/{id} - Reject provider account
  Future<void> rejectProvider(String id) async {
    try {
      final token = await _tokenManager.getAccessToken();
      await _dio.patch(
        ApiConstants.adminRejectProvider(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/admin/activate/{id} - Activate user account
  Future<void> activateUser(String id) async {
    try {
      final token = await _tokenManager.getAccessToken();
      await _dio.patch(
        ApiConstants.adminActivateUser(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /api/admin/deactivate/{id} - Deactivate user account
  Future<void> deactivateUser(String id) async {
    try {
      final token = await _tokenManager.getAccessToken();
      await _dio.patch(
        ApiConstants.adminDeactivateUser(id),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== HELPER METHODS ====================

  Map<String, dynamic> _handleResponse(Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('success') && data['success'] == true) {
          return data['data'] ?? data;
        }
        return data;
      }
      return {'data': response.data};
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  List<dynamic> _handleListResponse(Response response) {
    if (response.statusCode == 200) {
      if (response.data is List) {
        return response.data as List<dynamic>;
      } else if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data.containsKey('data') && data['data'] is List) {
          return data['data'] as List<dynamic>;
        }
      }
      return [];
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  String _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'];
        } else if (data is String) {
          return data;
        }
        return 'Server error: ${error.response!.statusCode}';
      } else if (error.type == DioExceptionType.connectionTimeout) {
        return 'Connection timeout. Please check your internet.';
      } else if (error.type == DioExceptionType.receiveTimeout) {
        return 'Server taking too long to respond.';
      } else if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection.';
      }
      return 'Network error. Please try again.';
    }
    return error.toString();
  }
}
