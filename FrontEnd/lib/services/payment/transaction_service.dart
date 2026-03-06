import 'package:dio/dio.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/transaction_model.dart';

class TransactionService {
  final Dio _dio;
  final TokenManager _tokenManager = TokenManager();

  TransactionService(this._dio);

  /// Get all transactions for current user
  Future<List<Transaction>> getUserTransactions() async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/payment/transactions',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((json) => Transaction.fromJson(json)).toList();
      } else {
        throw response.data['message'] ?? 'Failed to fetch transactions';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get transaction by ID
  Future<Transaction> getTransactionById(String transactionId) async {
    try {
      final token = await _tokenManager.getAccessToken();

      final response = await _dio.get(
        '${ApiConstants.baseUrl}/api/payment/transactions/$transactionId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.data['success'] == true) {
        return Transaction.fromJson(response.data['data']);
      } else {
        throw response.data['message'] ?? 'Failed to fetch transaction';
      }
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
