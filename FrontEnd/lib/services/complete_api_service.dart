import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:jwt_decode/jwt_decode.dart';

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




  Future<String> _getValidToken() async {
    final token = await _tokenManager.getAccessToken();

    if (token == null || token.isEmpty) {
      throw Exception('No token found - please login again');
    }

    bool expired = false;
    try {
      expired = Jwt.isExpired(token);
    } catch (_) {
      await _tokenManager.clearAll();
      throw Exception('Invalid token - please login again');
    }

    if (expired) {
      await _tokenManager.clearAll();
      throw Exception('Token expired - please login again');
    }

    return token;
  }

  // ==================== 1. AUTHENTICATION ENDPOINTS ====================

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
    String role = 'USER',
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

  Future<Map<String, dynamic>> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        data: {'email': email, 'otp': otp},
      );
      final data = _handleResponse(response);
      final token = data['token'] ?? data['accessToken'];
      if (token != null) {
        await _tokenManager.saveTokens(
          accessToken: token,
          refreshToken: data['refreshToken'],
          userId: data['userId'] ?? '',
          email: email,
          userName: data['userName'] ?? data['username'] ?? '',
        );
      }
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// ✅ FIXED: uses 'token' field (matches server response)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final data = _handleResponse(response);

      // ✅ Server returns 'token', not 'accessToken'
      final token = data['token'] ?? data['accessToken'];
      if (token != null) {
        await _tokenManager.saveTokens(
          accessToken: token,
          refreshToken: data['refreshToken'],
          userId: data['userId'] ?? '',
          email: email,
          userName: data['userName'] ?? data['username'] ?? '',
        );
      }
      return data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      final token = await _tokenManager.getAccessToken();
      await _dio.post(
        ApiConstants.logout,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      await _tokenManager.clearAll();
    } catch (e) {
      await _tokenManager.clearAll();
      throw _handleError(e);
    }
  }

  // ==================== 2. USER & PROFILE MANAGEMENT ====================

  Future<Map<String, dynamic>> getCurrentUserProfile() async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        '/api/users/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    String? address,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.put(
        '/api/users/profile',
        data: {
          'name': name,
          'phone': phone,
          if (address != null) 'address': address,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.patch(
        '/api/users/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getProvidersByCategory(String categoryId) async {
    try {
      final response =
      await _dio.get('/api/users/providers/category/$categoryId');
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

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

  Future<Map<String, dynamic>> verifyResetPasswordOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '/api/users/verify-otp',
        data: {'email': email, 'otp': otp},
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.resetPassword,
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 3. BOOKINGS ====================

  Future<Map<String, dynamic>> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingDate,
    String? description,
    String? location,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.post(
        '/api/bookings',
        data: {
          'providerId': providerId,
          'serviceId': serviceId,
          'bookingDate': bookingDate.toIso8601String(),
          if (description != null) 'description': description,
          if (location != null) 'location': location,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getMyBookings() async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        '/api/bookings/my-bookings',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/cancel',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getProviderRequests() async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        '/api/bookings/requests',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> acceptBooking(String bookingId) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/accept',
        data: {},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> rejectBooking(
      String bookingId, String reason) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/reject',
        data: {'reason': reason},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> completeBooking(String bookingId) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.patch(
        '/api/bookings/$bookingId/complete',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getAllBookings() async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        '/api/bookings/all',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 4. CHAT SYSTEM ====================

  Future<Map<String, dynamic>> sendChatMessage({
    required String requestId,
    required String message,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.post(
        '/api/chat/send',
        data: {'requestId': requestId, 'message': message},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getChatHistory(String requestId) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        '/api/chat/$requestId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> getUnreadMessageCount(String requestId) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        '/api/chat/$requestId/unread-count',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final data = _handleResponse(response);
      return data['count'] ?? 0;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 5. SERVICE CATEGORIES ====================

  /// GET /api/categories - Public, no auth needed
  Future<List<dynamic>> getActiveCategories() async {
    try {
      final response = await _dio.get(ApiConstants.categories);
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/admin/categories ✅
  Future<Map<String, dynamic>> createCategory({
    required String name,
    required String description,
    required String icon,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.post(
        ApiConstants.adminCategories,
        data: {'name': name, 'description': description, 'icon': icon},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/admin/categories/{id} ✅
  Future<Map<String, dynamic>> updateCategory({
    required String id,
    required String name,
    required String description,
    required String icon,
  }) async {
    try {
      final token = await _getValidToken();
      final response = await _dio.put(
        ApiConstants.adminUpdateCategory(id),
        data: {'name': name, 'description': description, 'icon': icon},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/admin/categories/{id} ✅
  Future<void> deleteCategory(String id) async {
    try {
      final token = await _getValidToken();
      await _dio.delete(
        ApiConstants.adminDeleteCategory(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== 6. ADMIN MANAGEMENT ====================

  Future<List<dynamic>> getAllUsers() async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        ApiConstants.adminUsers,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getAllProviders() async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        ApiConstants.adminProviders,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getPendingProviders() async {
    try {
      final token = await _getValidToken();
      final response = await _dio.get(
        ApiConstants.adminPendingProviders,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return _handleListResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> approveProvider(String id) async {
    try {
      final token = await _getValidToken();
      await _dio.patch(
        ApiConstants.adminApproveProvider(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rejectProvider(String id) async {
    try {
      final token = await _getValidToken();
      await _dio.patch(
        ApiConstants.adminRejectProvider(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> activateUser(String id) async {
    try {
      final token = await _getValidToken();
      await _dio.patch(
        ApiConstants.adminActivateUser(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deactivateUser(String id) async {
    try {
      final token = await _getValidToken();
      await _dio.patch(
        ApiConstants.adminDeactivateUser(id),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
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