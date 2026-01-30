import 'package:flutter/foundation.dart';
import 'package:HamroGharSewa/models/service_model.dart' as models;
import 'package:HamroGharSewa/services/service_api_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceApiService _serviceApiService;
  
  List<models.Service> _services = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  ServiceProvider(this._serviceApiService);

  List<models.Service> get services => _services;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Fetch all services
  Future<void> fetchServices() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _serviceApiService.getAllServices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all categories
  Future<void> fetchCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _serviceApiService.getAllCategories();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch services by category
  Future<void> fetchServicesByCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _services = await _serviceApiService.getServicesByCategory(categoryId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Search services
  List<models.Service> searchServices(String query) {
    if (query.isEmpty) return _services;
    
    final lowerQuery = query.toLowerCase();
    return _services.where((service) {
      return service.name.toLowerCase().contains(lowerQuery) ||
             service.description.toLowerCase().contains(lowerQuery) ||
             service.categoryName.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Admin: Create category
  Future<bool> createCategory({
    required String name,
    String? description,
    String? iconName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final category = await _serviceApiService.createCategory(
        name: name,
        description: description,
        iconName: iconName,
      );
      
      _categories.add(category);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Admin: Update category
  Future<bool> updateCategory({
    required String categoryId,
    required String name,
    String? description,
    String? iconName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedCategory = await _serviceApiService.updateCategory(
        categoryId: categoryId,
        name: name,
        description: description,
        iconName: iconName,
      );
      
      final index = _categories.indexWhere((c) => c.id == categoryId);
      if (index != -1) {
        _categories[index] = updatedCategory;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Admin: Delete category
  Future<bool> deleteCategory(String categoryId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _serviceApiService.deleteCategory(categoryId);
      _categories.removeWhere((c) => c.id == categoryId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _services = [];
    _categories = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
  /// Submit Provider Application (Mock)
  Future<bool> submitProviderApplication(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would call:
      // await _serviceApiService.submitProviderApplication(data);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Check Provider Status (Mock)
  Future<String> checkProviderStatus() async {
     // Simulate API call
     await Future.delayed(const Duration(milliseconds: 500));
     // Return 'NONE', 'PENDING', 'APPROVED', 'REJECTED'
     return 'NONE'; 
  }
}
