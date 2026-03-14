import 'package:dio/dio.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';

class PaymentService {
  final Dio _dio;
  final TokenManager _tokenManager = TokenManager();

  PaymentService(this._dio);

  Future<Map<String, dynamic>> initiateKhaltiPayment(int amount) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      // print('🔵 Initiating Khalti payment...');
      // print('🔵 Amount: $amount');
      // print('🔵 URL: ${ApiConstants.baseUrl}/api/payment/khalti/initiate');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/api/payment/khalti/initiate',
        data: {'amount': amount},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );



      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Payment initiation failed';
      }
    } on DioException catch (e) {
      print('🔴 Khalti payment error: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('🔴 Unexpected error: $e');
      throw 'Unexpected error: $e';
    }
  }


  Future<Map<String, dynamic>> verifyKhaltiPayment(String pidx) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/api/payment/khalti/verify',
        data: {'pidx': pidx},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Payment verification failed';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Initiate eSewa Payment
  Future<Map<String, dynamic>> initiateEsewaPayment(int amount) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      print('🟢 Initiating eSewa payment...');
      print('🟢 Amount: $amount');
      print('🟢 URL: ${ApiConstants.baseUrl}/api/payment/esewa/initiate?amount=$amount');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}/api/payment/esewa/initiate?amount=$amount',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('🟢 Response status: ${response.statusCode}');
      print('🟢 Response data: ${response.data}');

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Payment initiation failed';
      }
    } on DioException catch (e) {
      print('🔴 eSewa payment error: ${e.message}');
      print('🔴 Response: ${e.response?.data}');
      throw _handleError(e);
    } catch (e) {
      print('🔴 Unexpected error: $e');
      throw 'Unexpected error: $e';
    }
  }

  /// Verify eSewa Payment
  Future<Map<String, dynamic>> verifyEsewaPayment(String data) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/payment/esewa/verify?data=$data',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw response.data['message'] ?? 'Payment verification failed';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    print('🔴 DioException type: ${e.type}');
    print('🔴 Status code: ${e.response?.statusCode}');
    print('🔴 Response data: ${e.response?.data}');
    
    if (e.response != null) {
      final data = e.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'];
      }
      if (data is Map && data.containsKey('error')) {
        return data['error'];
      }
      return 'Server error (${e.response!.statusCode}): ${data.toString()}';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server is taking too long to respond.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to server. Please check if the backend is running.';
    } else {
      return 'Network error: ${e.message}';
    }
  }
}
