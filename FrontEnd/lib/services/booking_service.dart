import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/booking_model.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

class BookingService {
  final Dio _dio;
  final TokenManager _tokenManager = TokenManager();

  BookingService(this._dio);

  /// Create a new booking with validation
  Future<Booking> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingDate,
    String? description,
    String? location,
  }) async {
    // Validate inputs
    if (providerId.isEmpty) {
      throw 'Provider ID is required';
    }
    if (serviceId.isEmpty) {
      throw 'Service ID is required';
    }
    // Allow same-day bookings - only reject if date is in the past
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final bookingDay = DateTime(bookingDate.year, bookingDate.month, bookingDate.day);
    
    if (bookingDay.isBefore(today)) {
      throw 'Booking date cannot be in the past';
    }
    if (location == null || location.trim().isEmpty) {
      throw 'Location is required';
    }

    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.post(
        ApiConstants.createBooking,
        data: {
          'providerId': providerId,
          'serviceId': serviceId,
          'bookingDate': bookingDate.toIso8601String(),
          'description': description?.trim() ?? '',
          'location': location.trim(),
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all bookings for the current user
  Future<List<Booking>> getUserBookings({String? status}) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final endpoint = status != null 
          ? ApiConstants.userBookingsByStatus(status)
          : ApiConstants.userBookings;

      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final dynamic data = response.data;
      List<dynamic> bookingsList;
      
      if (data is List) {
        bookingsList = data;
      } else if (data is Map && data['data'] != null) {
        bookingsList = data['data'] as List;
      } else {
        bookingsList = [];
      }
      
      return bookingsList.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all bookings for the current provider
  Future<List<Booking>> getProviderBookings({String? status}) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final endpoint = status != null 
          ? ApiConstants.providerBookingsByStatus(status)
          : ApiConstants.providerBookings;

      final response = await _dio.get(
        endpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final dynamic data = response.data;
      List<dynamic> bookingsList;
      
      if (data is List) {
        bookingsList = data;
      } else if (data is Map && data['data'] != null) {
        bookingsList = data['data'] as List;
      } else {
        bookingsList = [];
      }
      
      return bookingsList.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get a specific booking by ID
  Future<Booking> getBookingById(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.get(
        ApiConstants.bookingById(bookingId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Accept booking - Provider only
  Future<Booking> acceptBooking(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.patch(
        ApiConstants.acceptBooking(bookingId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Reject booking - Provider only
  Future<Booking> rejectBooking(String bookingId, {String? reason}) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.patch(
        ApiConstants.rejectBooking(bookingId),
        data: {'reason': reason ?? 'Provider declined'},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Cancel booking - User only
  Future<Booking> cancelBooking(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.patch(
        ApiConstants.cancelBooking(bookingId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Complete booking
  Future<Booking> completeBooking(String bookingId) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.patch(
        ApiConstants.completeBooking(bookingId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Booking.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      return 'Server error: ${e.response!.statusCode}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond.';
    } else {
      return 'Network error. Please try again.';
    }
  }
}