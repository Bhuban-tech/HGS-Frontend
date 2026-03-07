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

      final dynamic responseData = response.data;
      final List<dynamic> data = (responseData is Map && responseData['data'] != null) 
          ? responseData['data'] 
          : responseData;
      return data.map((json) => Service.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Get all registered providers (approved)
  Future<List<dynamic>> getAllProviders() async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      final response = await _dio.get(
        ApiConstants.providers,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      final dynamic responseData = response.data;
      List<dynamic> rawList;
      if (responseData is Map && responseData['data'] != null) {
        rawList = responseData['data'] as List<dynamic>;
      } else if (responseData is List) {
        rawList = responseData;
      } else {
        rawList = [];
      }

      // Map backend fields to frontend expected fields
      return rawList.map((p) {
        // Debug: print provider data to see what fields are available
        print('🔍 Provider data: ${p.toString()}');
        
        return {
          'id': p['id'] ?? '',
          'name': p['userName'] ?? p['name'] ?? 'Unknown',
          'service': p['serviceCategoryName'] ?? p['categoryName'] ?? p['serviceCategory'] ?? 'Service Provider',
          'location': p['address'] ?? p['location'] ?? p['serviceLocation'] ?? 'Location not set',
          'status': (p['active'] == true) ? 'Available' : 'Busy',
          'rate': p['experienceYears'] != null ? '${p['experienceYears']} yrs exp' : 'Contact for rate',
          'email': p['email'] ?? '',
          'phone': p['phoneNumber'] ?? p['phone'] ?? '',
          'serviceCategoryId': p['serviceCategoryId'] ?? '',
          'active': p['active'] ?? false,
          'approved': p['approved'] ?? false,
        };
      }).toList();
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

      final dynamic responseData = response.data;
      final Map<String, dynamic> data = (responseData is Map && responseData['data'] != null)
          ? responseData['data'] as Map<String, dynamic>
          : responseData as Map<String, dynamic>;
      return Service.fromJson(data);
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

      final dynamic responseData = response.data;
      final List<dynamic> data = (responseData is Map && responseData['data'] != null) 
          ? responseData['data'] 
          : responseData;
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

      final dynamic responseData = response.data;
      final List<dynamic> data = (responseData is Map && responseData['data'] != null) 
          ? responseData['data'] 
          : responseData;
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

      final dynamic responseData = response.data;
      final Map<String, dynamic> data = (responseData is Map && responseData['data'] != null)
          ? responseData['data'] as Map<String, dynamic>
          : responseData as Map<String, dynamic>;
      return Category.fromJson(data);
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

      final dynamic responseData = response.data;
      final Map<String, dynamic> data = (responseData is Map && responseData['data'] != null)
          ? responseData['data'] as Map<String, dynamic>
          : responseData as Map<String, dynamic>;
      return Category.fromJson(data);
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

  /// Submit provider registration application
  Future<void> becomeProvider(Map<String, dynamic> data) async {
    try {
      final token = await _tokenManager.getAccessToken();
      
      await _dio.patch(
        ApiConstants.becomeProvider,
        data: data,
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
