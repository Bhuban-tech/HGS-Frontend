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
      final fullUrl = '${ApiConstants.baseUrl}${ApiConstants.userTransactions}';
      
      print('📡 Fetching transactions from: $fullUrl');
      print('📡 Token: ${token?.substring(0, 20)}...');

      final response = await _dio.get(
        fullUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response data: ${response.data}');

      // Handle different response formats
      final dynamic responseData = response.data;
      List<dynamic> transactionsList;

      if (responseData is List) {
        // Direct array response
        transactionsList = responseData;
        print('📡 Direct array format: ${transactionsList.length} transactions');
      } else if (responseData is Map) {
        // Check for success flag
        if (responseData['success'] == false) {
          throw responseData['message'] ?? 'Failed to fetch transactions';
        }
        // Extract data array
        transactionsList = responseData['data'] ?? [];
        print('📡 Map format: ${transactionsList.length} transactions');
      } else {
        transactionsList = [];
        print('📡 Unknown format, returning empty list');
      }

      return transactionsList.map((json) => Transaction.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  /// Get transaction by ID
  Future<Transaction> getTransactionById(String transactionId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      final fullUrl = '${ApiConstants.baseUrl}${ApiConstants.transactionById(transactionId)}';

      final response = await _dio.get(
        fullUrl,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Handle different response formats
      final dynamic responseData = response.data;
      
      if (responseData is Map) {
        if (responseData['success'] == false) {
          throw responseData['message'] ?? 'Failed to fetch transaction';
        }
        // Extract transaction data
        final transactionData = responseData['data'] ?? responseData;
        return Transaction.fromJson(transactionData);
      } else {
        throw 'Invalid response format';
      }
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      
      // Handle 404 - endpoint not found
      if (e.response!.statusCode == 404) {
        return 'Transaction history feature is not available yet. Please contact support.';
      }
      
      // Handle 401/403 - authentication issues
      if (e.response!.statusCode == 401 || e.response!.statusCode == 403) {
        return 'Authentication failed. Please login again.';
      }
      
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
