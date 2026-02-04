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
    if (bookingDate.isBefore(DateTime.now())) {
      throw 'Booking date must be in the future';
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
  Future<List<Booking>> getUserBookings() async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.userBookings,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Booking.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all bookings for the current provider
  Future<List<Booking>> getProviderBookings() async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.providerBookings,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Booking.fromJson(json)).toList();
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
