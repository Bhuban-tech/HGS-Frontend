import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/api_client.dart';

class ManageProvidersScreen extends StatefulWidget {
  const ManageProvidersScreen({super.key});

  @override
  State<ManageProvidersScreen> createState() => _ManageProvidersScreenState();
}

class _ManageProvidersScreenState extends State<ManageProvidersScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _providers = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _error;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _apiClient.get(ApiConstants.adminProviders),
        _apiClient.get(ApiConstants.categories),
      ]);

      final providersRes = results[0];
      final categoriesRes = results[1];

      if (providersRes.statusCode == 200 && categoriesRes.statusCode == 200) {
        final decodedProviders = jsonDecode(providersRes.body);
        final decodedCategories = jsonDecode(categoriesRes.body);
        setState(() {
          _providers = ((decodedProviders['data'] ?? []) as List)
              .where((p) => p != null)
              .toList();
          _categories = ((decodedCategories['data'] ?? []) as List)
              .where((c) => c != null)
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _getCategoryName(String? categoryId) {
    if (categoryId == null) return 'Not Assigned';
    final category = _categories.firstWhere(
          (c) => c['id'] == categoryId,
      orElse: () => null,
    );
    return category?['name'] ?? 'Unknown Category';
  }

  Future<void> _activateProvider(String id) async {
    try {
      final response =
      await _apiClient.patch(ApiConstants.adminActivateUser(id), null);
      if (response.statusCode == 200) {
        _showSnackBar('Provider activated successfully');
        _fetchData();
      } else {
        _showSnackBar('Failed to activate provider', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _deactivateProvider(String id) async {
    final confirmed = await _showConfirmDialog(
      'Deactivate Provider',
      'Are you sure you want to deactivate this provider?',
      confirmColor: Colors.orange,
    );
    if (confirmed != true) return;
    try {
      final response =
      await _apiClient.patch(ApiConstants.adminDeactivateUser(id), null);
      if (response.statusCode == 200) {
        _showSnackBar('Provider deactivated');
        _fetchData();
      } else {
        _showSnackBar('Failed to deactivate provider', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _approveProvider(String id) async {
    try {
      final response =
      await _apiClient.patch(ApiConstants.adminApproveProvider(id), null);
      if (response.statusCode == 200) {
        _showSnackBar('Provider approved successfully');
        _fetchData();
      } else {
        _showSnackBar('Failed to approve provider', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _rejectProvider(String id) async {
    final confirmed = await _showConfirmDialog(
      'Reject Provider',
      'Are you sure you want to reject this provider?',
      confirmColor: Colors.red,
    );
    if (confirmed != true) return;
    try {
      final response =
      await _apiClient.patch(ApiConstants.adminRejectProvider(id), null);
      if (response.statusCode == 200) {
        _showSnackBar('Provider rejected');
        _fetchData();
      } else {
        _showSnackBar('Failed to reject provider', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  Future<void> _removeProvider(String id) async {
    final confirmed = await _showConfirmDialog(
      'Remove Provider',
      'This will permanently delete this provider. This action cannot be undone.',
      confirmColor: Colors.red,
    );
    if (confirmed != true) return;
    try {
      final response = await _apiClient.delete('/api/admin/providers/$id');
      if (response.statusCode == 200) {
        _showSnackBar('Provider removed from database');
        _fetchData();
      } else {
        _showSnackBar('Failed to remove provider', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    }
  }

  void _showProviderDetails(Map<String, dynamic> provider) {
    final bool isActive = provider['active'] ?? false;
    final bool isApproved = provider['approved'] ?? false;
    final String role = provider['role'] ?? 'SERVICE_PROVIDER';
    final String categoryName =
    _getCategoryName(provider['serviceCategoryId']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Avatar + name + status badges
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: isActive
                          ? AppColors.primaryBlue
                          : Colors.grey.shade400,
                      child: Text(
                        (provider['userName'] ?? 'P')[0].toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      provider['userName'] ?? 'Unknown',
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Status badges row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Active/Inactive badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isActive
                                  ? Colors.green.shade300
                                  : Colors.red.shade300,
                            ),
                          ),
                          child: Text(
                            isActive ? '● Active' : '● Inactive',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Approved/Pending badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isApproved
                                ? Colors.blue.shade50
                                : Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isApproved
                                  ? Colors.blue.shade300
                                  : Colors.orange.shade300,
                            ),
                          ),
                          child: Text(
                            isApproved ? '✓ Approved' : '⏳ Pending',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isApproved
                                  ? Colors.blue.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // Details
              _detailRow(Icons.email, 'Email', provider['email'] ?? 'N/A'),
              _detailRow(
                  Icons.phone, 'Phone', provider['phoneNumber'] ?? 'N/A'),
              _detailRow(Icons.badge, 'Role', role),
              _detailRow(
                Icons.home_repair_service,
                'Service',
                categoryName,
                valueColor: AppColors.primaryBlue,
              ),
              _detailRow(
                Icons.verified,
                'Approval',
                isApproved ? 'Approved' : 'Pending Approval',
                valueColor: isApproved ? Colors.blue : Colors.orange,
              ),
              _detailRow(
                Icons.circle,
                'Status',
                isActive ? 'Active' : 'Inactive',
                valueColor: isActive ? Colors.green : Colors.red,
              ),

              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),

              // ✅ Approve/Reject if pending
              if (!isApproved) ...[
                const Text(
                  'Approval Actions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black54),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _approveProvider(provider['id'].toString());
                        },
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _rejectProvider(provider['id'].toString());
                        },
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // ✅ Activate/Deactivate + Remove
              const Text(
                'Account Actions',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black54),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        isActive
                            ? _deactivateProvider(provider['id'].toString())
                            : _activateProvider(provider['id'].toString());
                      },
                      icon: Icon(
                          isActive ? Icons.block : Icons.check_circle,
                          size: 18),
                      label: Text(isActive ? 'Deactivate' : 'Activate'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isActive ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _removeProvider(provider['id'].toString());
                      },
                      icon: const Icon(Icons.delete_forever, size: 18),
                      label: const Text('Remove'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primaryBlue),
          const SizedBox(width: 12),
          Text('$label: ',
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: Colors.black54)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(String title, String message,
      {Color confirmColor = Colors.red}) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
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

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  List<dynamic> get _activeProviders =>
      _providers.where((p) => p['active'] == true).toList();

  List<dynamic> get _inactiveProviders =>
      _providers.where((p) => p['active'] == false).toList();

  List<dynamic> get _pendingProviders =>
      _providers.where((p) => p['approved'] == false).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Providers',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabs: [
            Tab(text: 'All (${_providers.length})'),
            Tab(text: 'Active (${_activeProviders.length})'),
            Tab(text: 'Inactive (${_inactiveProviders.length})'),
            Tab(
              child: Row(
                children: [
                  const Text('Pending'),
                  if (_pendingProviders.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pendingProviders.length}',
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(_error!,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      )
          : TabBarView(
        controller: _tabController,
        children: [
          _buildProviderList(_providers),
          _buildProviderList(_activeProviders),
          _buildProviderList(_inactiveProviders),
          _buildProviderList(_pendingProviders),
        ],
      ),
    );
  }

  Widget _buildProviderList(List<dynamic> providers) {
    if (providers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No providers found',
                style:
                TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: providers.length,
        itemBuilder: (context, index) {
          final provider = providers[index];
          final bool isActive = provider['active'] ?? false;
          final bool isApproved = provider['approved'] ?? false;

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              onTap: () => _showProviderDetails(provider),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor:
                isActive ? AppColors.primaryBlue : Colors.grey.shade400,
                child: Text(
                  (provider['userName'] ?? 'P')[0].toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                provider['userName'] ?? 'Unknown',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(provider['email'] ?? ''),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.home_repair_service,
                          size: 12, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(
                        _getCategoryName(provider['serviceCategoryId']),
                        style: TextStyle(
                            fontSize: 11, color: AppColors.primaryBlue),
                      ),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Active badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Pending badge
                  if (!isApproved)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pending',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}