import 'package:flutter/foundation.dart';
import 'package:HamroGharSewa/models/service_model.dart' as models;
import 'package:HamroGharSewa/services/service_api_service.dart';

class ServiceProvider with ChangeNotifier {
  final ServiceApiService _serviceApiService;

  List<models.Service> _services = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // ── Provider data from server ──────────────────────────────────────────
  List<dynamic> _registeredProviders = [];
  List<dynamic> get registeredProviders =>
      List.unmodifiable(_registeredProviders);

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

  // ── Submit Provider Application — calls real API ──────
  Future<bool> submitProviderApplication(Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _serviceApiService.becomeProvider(data);
      
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

  /// Fetch all active providers from server
  Future<void> fetchProviders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _registeredProviders = await _serviceApiService.getAllProviders();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Check Provider Status (Mock)
  Future<String> checkProviderStatus() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 'NONE'; // 'NONE' | 'PENDING' | 'APPROVED' | 'REJECTED'
  }

  /// Toggle a provider's availability
  void toggleProviderStatus(int index) {
    if (index < 0 || index >= _registeredProviders.length) return;
    final current = _registeredProviders[index]['status'];
    _registeredProviders[index]['status'] =
    current == 'Available' ? 'Busy' : 'Available';
    notifyListeners();
  }

  /// Remove a provider from local list
  void removeProvider(int index) {
    if (index < 0 || index >= _registeredProviders.length) return;
    _registeredProviders.removeAt(index);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _services = [];
    _categories = [];
    _registeredProviders.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}