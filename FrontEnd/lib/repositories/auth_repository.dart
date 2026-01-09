import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/auth_response.dart';

class AuthRepository {
  final Dio _dio;
  final TokenManager _tokenManager = TokenManager();

  AuthRepository(this._dio) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenManager.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _tokenManager.clearAll();
            if (kDebugMode) print("Token expired or invalid - cleared storage");
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success && authResponse.accessToken != null) {
        await _saveAuthData(authResponse);
      }

      return authResponse;
    } on DioException catch (e) {
      return _handleDioError(e, "Login failed");
    } catch (e) {
      if (kDebugMode) print("Unexpected login error: $e");
      return AuthResponse(success: false, message: 'Unexpected error during login');
    }
  }

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'userName': name,
          'email': email,
          'phoneNumber': phone,
          'password': password,
        },
      );

      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      return _handleDioError(e, "Registration failed");
    } catch (e) {
      if (kDebugMode) print("Unexpected registration error: $e");
      return AuthResponse(success: false, message: 'Unexpected error during registration');
    }
  }

  Future<AuthResponse> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        ApiConstants.verifyOtp,
        queryParameters: {
          'email': email,
          'otp': otp,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      if (authResponse.success &&
          authResponse.accessToken != null &&
          authResponse.user != null) {
        await _saveAuthData(authResponse);
      }

      return authResponse;
    } on DioException catch (e) {
      return _handleDioError(e, "OTP verification failed");
    } catch (e) {
      if (kDebugMode) print("Unexpected OTP verification error: $e");
      return AuthResponse(success: false, message: 'Unexpected error during OTP verification');
    }
  }

  Future<void> logout() async {
    try {
      final token = await _tokenManager.getAccessToken();
      if (token != null && token.isNotEmpty) {
        await _dio.post(
          ApiConstants.logout,
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
            validateStatus: (status) => status! < 500,
          ),
        );
      }
    } on DioException catch (e) {
      if (kDebugMode) print("Logout API error (ignoring): $e");
    } catch (e) {
      if (kDebugMode) print("Unexpected logout error (ignoring): $e");
    } finally {
      await _tokenManager.clearAll();
    }
  }

  Future<bool> isAuthenticated() async {
    return await _tokenManager.isLoggedIn();
  }

  Future<Map<String, String>?> getCurrentUser() async {
    return await _tokenManager.getUserData();
  }

  // Fixed: Make refreshToken optional and nullable
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    if (authResponse.accessToken == null) {
      throw Exception("Access token is null");
    }

    if (authResponse.user == null) {
      await _tokenManager.saveTokens(
        accessToken: authResponse.accessToken!,
        userId: '',
        email: '',
        userName: '',
        refreshToken: '', // Now safe - empty string instead of null
      );
    } else {
      await _tokenManager.saveTokens(
        accessToken: authResponse.accessToken!,
        userId: authResponse.user!.id,
        email: authResponse.user!.email,
        userName: authResponse.user!.userName,
        refreshToken: '', // Pass empty string (or null if you update TokenManager)
      );
    }
  }

  AuthResponse _handleDioError(DioException e, String fallbackMessage) {
    String message = fallbackMessage;

    if (e.response != null) {
      try {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData['message'] != null) {
          message = errorData['message'];
        } else if (errorData is String) {
          message = errorData;
        }
      } catch (_) {
        if (kDebugMode) print("Could not parse error response");
      }

      switch (e.response!.statusCode) {
        case 400:
          message = message.isEmpty ? "Invalid request" : message;
          break;
        case 401:
          message = message.isEmpty ? "Invalid email or password" : message;
          break;
        case 403:
          message = message.isEmpty ? "Account suspended or access denied" : message;
          break;
        case 404:
          message = message.isEmpty ? "User not found" : message;
          break;
        case 409:
          message = message.isEmpty ? "User already exists" : message;
          break;
        case 422:
          message = message.isEmpty ? "Invalid data provided" : message;
          break;
        case 500:
        case 502:
        case 503:
          message = "Server error. Please try again later";
          break;
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      message = "Connection timeout. Please check your internet";
    } else if (e.type == DioExceptionType.connectionError) {
      message = "No internet connection";
    } else {
      message = "Unable to connect. Check your internet";
    }

    if (kDebugMode) print("DioError: ${e.type} - $message");

    return AuthResponse(success: false, message: message);
  }
}