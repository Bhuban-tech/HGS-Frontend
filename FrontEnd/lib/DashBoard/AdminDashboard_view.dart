import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/services/api_client.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:HamroGharSewa/view/admin/AdminDrawer.dart';
import 'dart:convert';

class ServiceAdminApp extends StatefulWidget {
  const ServiceAdminApp({super.key});

  @override
  State<ServiceAdminApp> createState() => _ServiceAdminAppState();
}

class _ServiceAdminAppState extends State<ServiceAdminApp> {
  final ApiClient _apiClient = ApiClient();
  final TokenManager _tokenManager = TokenManager();

  List<dynamic> _categories = [];
  List<dynamic> _pendingProviders = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, String>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadDashboardData();
  }

  Future<void> _loadUserData() async {
    final data = await _tokenManager.getUserData();
    if (mounted) setState(() => _userData = data);
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final results = await Future.wait([
        _apiClient.get(ApiConstants.categories),
        _apiClient.get(ApiConstants.adminPendingProviders),
      ]);

      final categoriesRes = results[0];
      final pendingRes = results[1];

      if (categoriesRes.statusCode == 200) {
        final decoded = jsonDecode(categoriesRes.body);
        _categories = ((decoded['data'] ?? []) as List)
            .where((c) => c != null)
            .toList();
      }

      if (pendingRes.statusCode == 200) {
        final decoded = jsonDecode(pendingRes.body);
        _pendingProviders = ((decoded['data'] ?? []) as List)
            .where((p) => p != null)
            .toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading dashboard data: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _approveProvider(String id) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.patch(ApiConstants.adminApproveProvider(id), null);
      if (response.statusCode == 200) {
        _showSnackBar('Provider approved successfully');
        _loadDashboardData();
      } else {
        _showSnackBar('Failed to approve provider', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
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
      final response = await _apiClient.patch(ApiConstants.adminRejectProvider(id), null);
      if (response.statusCode == 200) {
        _showSnackBar('Provider rejected');
        _loadDashboardData();
      } else {
        _showSnackBar('Failed to reject provider', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showProviderDetails(Map<String, dynamic> provider) {
    final String categoryName = _getCategoryName(provider['serviceCategoryId']);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
              child: Text(
                (provider['userName'] ?? 'P')[0].toUpperCase(),
                style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider['userName'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    provider['email'] ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              _detailRow(Icons.email, 'Email', provider['email'] ?? 'N/A'),
              _detailRow(Icons.phone, 'Phone', provider['phoneNumber'] ?? 'N/A'),
              _detailRow(Icons.badge, 'Role', provider['role'] ?? 'SERVICE_PROVIDER'),
              _detailRow(
                Icons.home_repair_service,
                'Service Category',
                categoryName,
                valueColor: categoryName == 'Not Assigned' ? Colors.red : AppColors.primaryBlue,
              ),
              if (provider['address'] != null && provider['address'].toString().isNotEmpty)
                _detailRow(Icons.location_on, 'Address', provider['address']),
              if (provider['experienceYears'] != null)
                _detailRow(Icons.work_history, 'Experience', '${provider['experienceYears']} years'),
              const SizedBox(height: 16),
              const Text(
                'Note: This provider is pending approval. Approve to activate their account.',
                style: TextStyle(fontSize: 12, color: Colors.orange, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String id) async {
    final confirmed = await _showConfirmDialog(
      'Delete Category',
      'Are you sure you want to delete this category?',
    );
    if (confirmed != true) return;

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.delete(
        ApiConstants.adminDeleteCategory(id), // DELETE /api/admin/categories/{id}
      );
      if (response.statusCode == 200) {
        _showSnackBar('Category deleted successfully!');
        _loadDashboardData();
      } else {
        _showSnackBar('Failed to delete category (${response.statusCode})', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleCategoryStatus(String id, bool setActive) async {
    try {
      // First, find the current category data
      final categoryToToggle = _categories.firstWhere(
        (c) => c['id'].toString() == id,
        orElse: () => null,
      );
      
      if (categoryToToggle == null) {
        _showSnackBar('Category not found', isError: true);
        return;
      }

      // Use PUT to update with all fields plus the new isActive status
      final response = await _apiClient.put(
        ApiConstants.adminUpdateCategory(id),
        {
          'name': categoryToToggle['name'],
          'description': categoryToToggle['description'] ?? '',
          'iconName': categoryToToggle['iconName'] ?? categoryToToggle['icon'] ?? '',
          'isActive': setActive,
        },
      );
      
      print('Toggle Response Status: ${response.statusCode}');
      print('Toggle Request Data: {"name": "${categoryToToggle['name']}", "description": "${categoryToToggle['description'] ?? ''}", "iconName": "${categoryToToggle['iconName'] ?? categoryToToggle['icon'] ?? ''}", "isActive": $setActive}');
      print('Toggle Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print('Decoded response: $decoded');
        
        // Check for success in response
        bool success = decoded['success'] == true || decoded['status'] == 'success';
        
        if (success || response.statusCode == 200) {
          _showSnackBar('Category ${setActive ? 'activated' : 'deactivated'}');
          _loadDashboardData();
        } else {
          _showSnackBar(decoded['message'] ?? 'Failed to update category', isError: true);
        }
      } else {
        _showSnackBar('Failed to update category (${response.statusCode})', isError: true);
      }
    } catch (e) {
      print('Toggle Error: $e');
      _showSnackBar('Error: $e', isError: true);
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

  Widget _detailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.black54)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Confirm'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'N/A';
    final category = _categories.firstWhere(
      (c) => c != null && c['id'].toString() == categoryId,
      orElse: () => null,
    );
    return category?['name'] ?? 'Unknown';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      drawer: const AdminDrawer(),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 2,
        title: const Text(
          "Admin Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () async {
              await TokenManager().forceLogout();
              if (context.mounted) {
                await TokenManager().logout(context);
              }
            },
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, '/admin-profile');
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  (_userData?['userName'] ?? 'A')[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadDashboardData,
            color: AppColors.primaryBlue,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome card
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),

                  // Stats row
                  _buildStatsRow(),
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
                          Expanded(
                            child: Text(
                              _errorMessage,
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: Colors.red[700], size: 20),
                            onPressed: () =>
                                setState(() => _errorMessage = ''),
                          ),
                        ],
                      ),
                    ),

                  // Pending Providers section
                  _buildPendingProvidersSection(),
                  const SizedBox(height: 20),

                  // Categories section
                  _buildCategoriesSection(),
                ],
              ),
            ),
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
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue),
                      ),
                      const SizedBox(height: 16),
                      const Text('Loading...',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final name = _userData?['userName'] ?? 'Admin';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue,
            AppColors.primaryBlue.withOpacity(0.8)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $name!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your platform from here',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final active = _categories
        .where((c) => c != null && c['active'] == true)
        .length;

    final inactive = _categories
        .where((c) => c != null && c['active'] == false)
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.category,
            'Categories',
            '${_categories.length}',
            AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.check_circle,
            'Active',
            '$active',
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.block,
            'Inactive',
            '$inactive',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildPendingProvidersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
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
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.pending_actions,
                        color: Colors.orange, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text("Pending Provider Requests",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              if (_pendingProviders.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_pendingProviders.length}',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          if (_pendingProviders.isEmpty && !_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No pending requests',
                    style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pendingProviders.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final provider = _pendingProviders[index];
                return Column(
                  children: [
                    // Provider Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with avatar and name
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                                child: Text(
                                  (provider['userName'] ?? 'P')[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider['userName'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      provider['email'] ?? '',
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 12),
                          const Divider(height: 1),
                          const SizedBox(height: 12),
                          
                          // Info chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                Icons.category,
                                _getCategoryName(provider['serviceCategoryId']),
                                AppColors.primaryBlue,
                              ),
                              if (provider['experienceYears'] != null)
                                _buildInfoChip(
                                  Icons.work_history,
                                  "${provider['experienceYears']} years exp",
                                  Colors.orange,
                                ),
                              if (provider['address'] != null && provider['address'].toString().isNotEmpty)
                                _buildInfoChip(
                                  Icons.location_on,
                                  provider['address'],
                                  Colors.red,
                                ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _showProviderDetails(provider),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.primaryBlue,
                                    side: BorderSide(color: AppColors.primaryBlue.withOpacity(0.5)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'View Details',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _approveProvider(provider['id'].toString()),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _rejectProvider(provider['id'].toString()),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: BorderSide(color: Colors.red.withOpacity(0.5)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration:
            BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
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
                    child: Icon(Icons.category,
                        color: AppColors.primaryBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text("Service Categories",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 17)),
                ],
              ),
              Text(
                '${_categories.length} total',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (_categories.isEmpty && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.category_outlined,
                        size: 64, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text('No categories yet',
                        style:
                        TextStyle(color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      'Use the drawer to create a new category',
                      style:
                      TextStyle(color: Colors.grey[400], fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = _categories[index];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.home_repair_service,
                            color: AppColors.primaryBlue, size: 22),
                      ),
                      const SizedBox(width: 14),

                      // Name & description
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category['name'] ?? 'Unnamed',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            if (category['description'] != null &&
                                category['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  category['description'],
                                  style: TextStyle(
                                      color: Colors.grey[500], fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () =>
                            _deleteCategory(category['id'].toString()),
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}