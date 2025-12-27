import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/models/service_provider.dart';
import 'package:HamroGharSewa/services/api_client.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:http/http.dart' as http;

class ServiceAdminApp extends StatefulWidget {
  const ServiceAdminApp({super.key});

  @override
  State<ServiceAdminApp> createState() => _ServiceAdminAppState();
}

class _ServiceAdminAppState extends State<ServiceAdminApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _categoryController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();

  final _apiClient = ApiClient();
  final _tokenManager = TokenManager();

  List<ServiceProvider> _providers = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, String>? _userData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    _loadUserData();
    _loadProviders();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _categoryController.dispose();
    _categoryDescriptionController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    _loadProviders();
  }

  Future<void> _loadUserData() async {
    final data = await _tokenManager.getUserData();
    if (mounted) {
      setState(() => _userData = data);
    }
  }

  Future<void> _loadProviders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final endpoint = _tabController.index == 0
          ? ApiConstants.adminProviders
          : ApiConstants.adminPendingProviders;

      final response = await _apiClient.get(endpoint);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        List<dynamic> dataList = [];
        if (responseData is Map && responseData['success'] == true) {
          dataList = responseData['data'] as List<dynamic>? ?? [];
        } else if (responseData is List) {
          dataList = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          dataList = responseData['data'] as List<dynamic>? ?? [];
        }

        if (mounted) {
          setState(() {
            _providers = dataList
                .map((json) => ServiceProvider.fromJson(json))
                .toList();
            _isLoading = false;
          });
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Session expired. Please login again.';
            _isLoading = false;
          });
          await _tokenManager.logout(context);
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Failed to load providers: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading providers: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Please enter a category name', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.post(
        ApiConstants.adminCategories,
        {
          'name': name,
          'description': _categoryDescriptionController.text.trim(),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _showSnackBar(
          responseData['message'] ?? 'Category created successfully!',
        );
        _categoryController.clear();
        _categoryDescriptionController.clear();
      } else if (response.statusCode == 401) {
        _showSnackBar('Session expired. Please login again.', isError: true);
        await _tokenManager.logout(context);
      } else {
        try {
          final errorData = jsonDecode(response.body);
          _showSnackBar(
            errorData['message'] ?? 'Failed to create category',
            isError: true,
          );
        } catch (_) {
          _showSnackBar(
            'Failed to create category: ${response.statusCode}',
            isError: true,
          );
        }
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveProvider(String id) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.patch(
        ApiConstants.adminApproveProvider(id),
        {},
      );
      if (response.statusCode == 200) {
        _showSnackBar('Provider approved successfully!');
        await _loadProviders();
      } else {
        _handleErrorResponse(response, 'approve');
      }
    } catch (e) {
      _showSnackBar('Error approving provider: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectProvider(String id) async {
    final confirmed = await _showConfirmDialog(
      'Reject Provider',
      'Are you sure you want to reject this provider?',
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.patch(
        ApiConstants.adminRejectProvider(id),
        {},
      );
      if (response.statusCode == 200) {
        _showSnackBar('Provider rejected successfully!');
        await _loadProviders();
      } else {
        _handleErrorResponse(response, 'reject');
      }
    } catch (e) {
      _showSnackBar('Error rejecting provider: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deactivateProvider(String id) async {
    final confirmed = await _showConfirmDialog(
      'Deactivate Provider',
      'Are you sure you want to deactivate this provider?',
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.patch(
        ApiConstants.adminDeactivateUser(id),
        {},
      );
      if (response.statusCode == 200) {
        _showSnackBar('Provider deactivated successfully!');
        await _loadProviders();
      } else {
        _handleErrorResponse(response, 'deactivate');
      }
    } catch (e) {
      _showSnackBar('Error deactivating provider: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleErrorResponse(http.Response response, String action) {
    if (response.statusCode == 401) {
      _showSnackBar('Session expired. Please login again.', isError: true);
      _tokenManager.logout(context);
    } else {
      try {
        final errorData = jsonDecode(response.body);
        _showSnackBar(
          errorData['message'] ?? 'Failed to $action provider',
          isError: true,
        );
      } catch (_) {
        _showSnackBar(
          'Failed to $action provider: ${response.statusCode}',
          isError: true,
        );
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          Column(
            children: [
              // Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 28),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                              onPressed: () => _showSnackBar('Notifications coming soon!'),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<dynamic>(
                              offset: const Offset(0, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.white,
                                  child: Text(
                                    _userData?['userName']?.isNotEmpty == true
                                        ? _userData!['userName']![0].toUpperCase()
                                        : 'A',
                                    style: TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
                                PopupMenuItem(
                                  enabled: false,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userData?['userName'] ?? 'Admin',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text(
                                        _userData?['email'] ?? '',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  child: const Row(
                                    children: [
                                      Icon(Icons.logout, size: 20),
                                      SizedBox(width: 12),
                                      Text('Logout'),
                                    ],
                                  ),
                                  onTap: () async {
                                    await Future.delayed(Duration.zero);
                                    await _tokenManager.logout(context);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Admin Dashboard',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primaryBlue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primaryBlue,
                  tabs: const [
                    Tab(text: 'All Providers'),
                    Tab(text: 'Pending'),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadProviders,
                  color: AppColors.primaryBlue,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildProvidersList(),
                      _buildProvidersList(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue)),
                      const SizedBox(height: 16),
                      const Text('Processing...', style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProvidersList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Statistics
          _buildStatisticsRow(),
          const SizedBox(height: 20),

          // Error message
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_errorMessage, style: TextStyle(color: Colors.red[700]))),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red[700], size: 20),
                    onPressed: () => setState(() => _errorMessage = ''),
                  ),
                ],
              ),
            ),

          // Create Category Card
          _createCategoryCard(),
          const SizedBox(height: 20),

          // Service Providers Card
          _serviceProvidersCard(),
        ],
      ),
    );
  }

  Widget _buildStatisticsRow() {
    final total = _providers.length;
    final active = _providers.where((p) => p.active).length;
    final pending = _providers.where((p) => !p.active).length;

    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.people, 'Total', '$total', AppColors.primaryBlue)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.check_circle, 'Active', '$active', Colors.green)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.pending, 'Pending', '$pending', Colors.orange)),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _createCategoryCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.category, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              const Text("Create Service Category", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(
              labelText: "Category Name",
              hintText: "e.g. Home Cleaning, Plumbing",
              prefixIcon: Icon(Icons.edit, color: AppColors.primaryBlue),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _categoryDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Description (Optional)",
              hintText: "Brief description...",
              prefixIcon: Icon(Icons.description, color: AppColors.primaryBlue),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _createCategory,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Create Category", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceProvidersCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.people, color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text("Service Providers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: AppColors.primaryBlue),
                onPressed: _isLoading ? null : _loadProviders,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_providers.isEmpty && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No providers found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              ),
            )
          else
            ..._providers.map((provider) => _providerTile(provider)),
        ],
      ),
    );
  }

  Widget _providerTile(ServiceProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: provider.active ? Colors.green.withOpacity(0.3) : Colors.orange.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: provider.active ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  child: Text(
                    provider.userName.isNotEmpty ? provider.userName[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: provider.active ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.email_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Expanded(child: Text(provider.email, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(provider.phoneNumber, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: provider.active ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  provider.active ? 'Active' : 'Pending',
                  style: TextStyle(
                    color: provider.active ? Colors.green : Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              if (!provider.active) ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _approveProvider(provider.id),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text("Approve"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _rejectProvider(provider.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text("Reject"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : () => _deactivateProvider(provider.id),
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text("Deactivate"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}