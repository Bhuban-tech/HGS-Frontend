
import 'package:HamroGharSewa/view/admin/AdminDrawer.dart';
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/models/service_provider.dart';
import 'package:HamroGharSewa/services/api_service.dart';
import 'package:HamroGharSewa/services/token_manager.dart';


class ServiceAdminApp extends StatefulWidget {
  const ServiceAdminApp({super.key});

  @override
  State<ServiceAdminApp> createState() => _ServiceAdminAppState();
}

class _ServiceAdminAppState extends State<ServiceAdminApp>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _apiService = ApiService(); // ← Use ApiService singleton
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
      List<dynamic> data;
      if (_tabController.index == 0) {
        data = await _apiService.getAllProviders();
      } else {
        data = await _apiService.getPendingProviders();
      }

      if (mounted) {
        setState(() {
          _providers = data
              .map((json) => ServiceProvider.fromJson(json))
              .toList();
          _isLoading = false;
        });
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

  Future<void> _approveProvider(String id) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.approveProvider(id);
      _showSnackBar('Provider approved successfully!');
      await _loadProviders();
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
      await _apiService.rejectProvider(id);
      _showSnackBar('Provider rejected successfully!');
      await _loadProviders();
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
      await _apiService.deactivateProvider(
        id,
      ); // Assumes method exists in ApiService
      _showSnackBar('Provider deactivated successfully!');
      await _loadProviders();
    } catch (e) {
      _showSnackBar('Error deactivating provider: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ), // Added margin for better spacing
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
    drawer: const AdminDrawer(),
    appBar: AppBar(
    title: const Text(
    'Admin Dashboard',
    style: TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 22,
      color: Colors.white
    ),
    ),
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,           // affects back button / other icons
      iconTheme: const IconThemeData(
        color: Colors.white,                    // ← makes hamburger (drawer) icon white
      ),
    elevation: 2,
    actions: [
    const SizedBox(width: 4),
    PopupMenuButton<dynamic>(
    offset: const Offset(0, 50),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Container(
    margin: const EdgeInsets.only(right: 16),
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
    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) {
    await _tokenManager.logout(context);
    }
    },
    ),
    ],
    ),
    ],
    ),

      // Added separate drawer
      backgroundColor: Colors.blue[50],
      body: Stack(
        children: [
          Column(
            children: [
              // Header
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
                    children: [_buildProvidersList(), _buildProvidersList()],
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
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Processing...',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
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
    final filteredProviders = _tabController.index == 0
        ? _providers
        : _providers.where((p) => !p.active).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Statistics (based on all providers)
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
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red[700], size: 20),
                    onPressed: () => setState(() => _errorMessage = ''),
                  ),
                ],
              ),
            ),

          // Service Providers Card (removed category card)
          _serviceProvidersCard(filteredProviders),
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
        Expanded(
          child: _buildStatCard(
            Icons.people,
            'Total',
            '$total',
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
            Icons.pending,
            'Pending',
            '$pending',
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _serviceProvidersCard(List<ServiceProvider> providers) {
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
                    child: Icon(
                      Icons.people,
                      color: AppColors.primaryBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Service Providers",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
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

          if (providers.isEmpty && !_isLoading)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No providers found',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            ...providers.map((provider) => _providerTile(provider)),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
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
                    color: provider.active
                        ? Colors.green.withOpacity(0.3)
                        : Colors.orange,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: provider.active
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  child: Text(
                    provider.userName.isNotEmpty
                        ? provider.userName[0].toUpperCase()
                        : '?',
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
                    Text(
                      provider.userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            provider.email,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          provider.phoneNumber,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: provider.active
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
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
                    onPressed: _isLoading
                        ? null
                        : () => _approveProvider(provider.id),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text("Approve"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _rejectProvider(provider.id),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text("Reject"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _deactivateProvider(provider.id),
                    icon: const Icon(Icons.block, size: 18),
                    label: const Text("Deactivate"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
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
