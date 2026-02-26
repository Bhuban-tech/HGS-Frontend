import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/models/service_model.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

class ServiceApiService {
  final Dio _dio;
  final TokenManager _tokenManager = TokenManager();

  ServiceApiService(this._dio);

  Future<List<Service>> getAllServices() async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.services,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Service.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get service by ID
  Future<Service> getServiceById(String serviceId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.serviceById(serviceId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Service.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get services by category
  Future<List<Service>> getServicesByCategory(String categoryId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.servicesByCategory,
        queryParameters: {'categoryId': categoryId},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Service.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all categories
  Future<List<Category>> getAllCategories() async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.categories,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((json) => Category.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Admin: Create category
  Future<Category> createCategory({
    required String name,
    String? description,
    String? iconName,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.post(
        ApiConstants.adminCategories,
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (iconName != null) 'iconName': iconName,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Category.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Admin: Update category
  Future<Category> updateCategory({
    required String categoryId,
    required String name,
    String? description,
    String? iconName,
  }) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.put(
        ApiConstants.adminUpdateCategory(categoryId),
        data: {
          'name': name,
          if (description != null) 'description': description,
          if (iconName != null) 'iconName': iconName,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return Category.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Admin: Delete category
  Future<void> deleteCategory(String categoryId) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      await _dio.delete(
        ApiConstants.adminDeleteCategory(categoryId),
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
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
