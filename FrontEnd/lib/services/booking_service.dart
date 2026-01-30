import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/booking_model.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

class BookingService {
  final Dio _dio;
  final TokenManager _tokenManager = TokenManager();

  BookingService(this._dio);

  /// Create a new booking
  Future<Booking> createBooking({
    required String providerId,
    required String serviceId,
    required DateTime bookingDate,
    String? description,
    String? location,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.post(
        ApiConstants.createBooking,
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

  /// Update booking status (ACCEPT/REJECT) - Provider only
  Future<Booking> updateBookingStatus(String bookingId, String status) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.put(
        ApiConstants.updateBookingStatus(bookingId),
        data: {'status': status},
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
