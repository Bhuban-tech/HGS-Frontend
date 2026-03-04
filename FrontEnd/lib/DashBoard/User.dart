import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/view/booking/bookingPage_view.dart';
import 'package:HamroGharSewa/providers/service_provider.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:HamroGharSewa/route/app_routes.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TokenManager _tokenManager = TokenManager();
  String searchQuery = '';
  String userName = 'User';
  String userEmail = '';
  String? _selectedCategory;
  int _currentIndex = 0;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Plumbing', 'icon': Icons.plumbing_rounded, 'color': AppColors.serviceBlue},
    {'title': 'Painting', 'icon': Icons.format_paint_rounded, 'color': AppColors.servicePurple},
    {'title': 'Electrical', 'icon': Icons.electrical_services_rounded, 'color': AppColors.serviceOrange},
    {'title': 'Carpenter', 'icon': Icons.handyman_rounded, 'color': AppColors.serviceTeal},
    {'title': 'Cleaning', 'icon': Icons.cleaning_services_rounded, 'color': AppColors.servicePink},
    {'title': 'Garden', 'icon': Icons.yard_rounded, 'color': AppColors.serviceGreen},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
    _loadUserName();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ServiceProvider>(context, listen: false).fetchProviders();
    });
  }

  Future<void> _loadUserName() async {
    final userData = await _tokenManager.getUserData();
    if (userData != null && mounted) {
      setState(() {
        userName = userData['userName'] ?? 'User';
        userEmail = userData['email'] ?? 'U';
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = Provider.of<ServiceProvider>(context);
    final allProviders = serviceProvider.registeredProviders;

    final filteredProviders = allProviders.where((p) {
      if (_selectedCategory != null) {
        final providerService = (p['service'] as String).toLowerCase().trim();
        final selected = _selectedCategory!.toLowerCase().trim();
        const categoryMap = {
          'carpenter': 'carpentry',
          'garden': 'gardening',
        };
        final mapped = categoryMap[selected] ?? selected;
        if (!providerService.contains(mapped) && !mapped.contains(providerService)) {
          return false;
        }
      }
      final q = searchQuery.toLowerCase();
      if (q.isEmpty) return true;
      return (p['service'] as String).toLowerCase().contains(q) ||
          (p['name'] as String).toLowerCase().contains(q) ||
          (p['location'] as String).toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header with overlapping search bar ──────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 48,
                  left: 24,
                  right: 24,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  children: [
                    PopupMenuButton<String>(
                      offset: const Offset(0, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onSelected: (value) async {
                        if (value == 'logout') {
                          await TokenManager().clearAll();
                          if (context.mounted) {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.login,
                                  (route) => false,
                            );
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: AppColors.error),
                              SizedBox(width: 8),
                              Text(
                                'Logout',
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Text(
                          (userEmail.isNotEmpty ? userEmail[0] : userName[0]).toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
                            'Welcome Back,',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search bar overlapping bottom edge
              Positioned(
                bottom: -28,
                left: 20,
                right: 20,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => searchQuery = v),
                      decoration: const InputDecoration(
                        hintText: 'Search for services...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        icon: Icon(Icons.search_rounded, color: AppColors.textLight),
                        suffixIcon: Icon(
                          Icons.tune_rounded,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ── Scrollable body ─────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Categories header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, i) => _buildCategoryItem(_categories[i]),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Promo Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2D3748), Color(0xFF1A202C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        image: DecorationImage(
                          image: const NetworkImage(
                            'https://images.unsplash.com/photo-1621905251189-08b45d6a269e?q=80&w=800&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
                            Colors.black.withValues(alpha: 0.6),
                            BlendMode.darken,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'OFFER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Get 20% Off on\nYour First Service',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textDark,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Popular Services header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCategory != null
                                ? '$_selectedCategory Providers'
                                : 'Popular Services',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (_selectedCategory != null)
                          GestureDetector(
                            onTap: () => setState(() => _selectedCategory = null),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Clear',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.close_rounded,
                                    size: 14,
                                    color: AppColors.primaryBlue,
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (allProviders.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${allProviders.length} available',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Provider list or empty state
                  filteredProviders.isEmpty
                      ? _buildEmptyState(_selectedCategory)
                      : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredProviders.length,
                    itemBuilder: (context, i) =>
                        _buildProviderCard(filteredProviders[i]),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(String? selectedCategory) {
    final bool isFiltered = selectedCategory != null;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              isFiltered ? Icons.filter_list_off_rounded : Icons.search_off_rounded,
              size: 56,
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              isFiltered ? 'No $selectedCategory providers yet' : 'No providers yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'No one has registered as a $selectedCategory provider yet. Be the first!'
                  : 'Be the first! Tap "Become a Provider" below to register your services.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            if (isFiltered) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => _selectedCategory = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Show all providers',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Category chip ─────────────────────────────────────────────────────────
  Widget _buildCategoryItem(Map<String, dynamic> service) {
    final title = service['title'] as String;
    final color = service['color'] as Color;
    final isSelected = _selectedCategory == title;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedCategory = isSelected ? null : title;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              Hero(
                tag: 'category_$title',
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [color.withValues(alpha: 0.9), color]
                          : [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: isSelected ? Border.all(color: color, width: 2.5) : null,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: isSelected ? 0.45 : 0.2),
                        blurRadius: isSelected ? 18 : 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: isSelected ? Colors.white : color,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? color : AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Provider card ─────────────────────────────────────────────────────────
  Widget _buildProviderCard(Map<String, dynamic> provider) {
    final bool isAvailable = provider['status'] == 'Available';

    return Hero(
      tag: 'provider_${provider['name']}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.1),
                          AppColors.primaryPurple.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.1),
                        width: 2,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            _getCategoryIcon(provider['service'] ?? ''),
                            size: 38,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: isAvailable ? AppColors.success : Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service title + status badge
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                provider['service'] ?? '',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isAvailable
                                      ? [
                                    AppColors.success.withValues(alpha: 0.15),
                                    AppColors.success.withValues(alpha: 0.08),
                                  ]
                                      : [
                                    Colors.orange.withValues(alpha: 0.15),
                                    Colors.orange.withValues(alpha: 0.08),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isAvailable ? Icons.check_circle : Icons.access_time,
                                    size: 12,
                                    color: isAvailable ? AppColors.success : Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    provider['status'] ?? '',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: isAvailable ? AppColors.success : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Name
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 15, color: AppColors.textMedium),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                provider['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMedium,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Location
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textLight),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                provider['location'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textLight,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Rate + Book button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  provider['rate'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookingPage(providerData: provider),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.4),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Book Now',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String service) {
    final s = service.toLowerCase();
    if (s.contains('plumb')) return Icons.plumbing_rounded;
    if (s.contains('paint')) return Icons.format_paint_rounded;
    if (s.contains('elect')) return Icons.electrical_services_rounded;
    if (s.contains('handy') || s.contains('carp')) return Icons.handyman_rounded;
    if (s.contains('clean')) return Icons.cleaning_services_rounded;
    if (s.contains('yard') || s.contains('gard')) return Icons.yard_rounded;
    return Icons.person_rounded;
  }

  // ── Bottom navigation bar ─────────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0:
              break;
            case 1:
              Navigator.pushNamed(context, AppRoutes.history);
              break;
            case 2:
              Navigator.pushNamed(context, AppRoutes.chat);
              break;
            case 3:
              Navigator.pushNamed(context, AppRoutes.profile);
              break;
          }
        },
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.home_rounded, size: 26),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.calendar_today_rounded, size: 24),
            ),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.chat_bubble_rounded, size: 24),
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Icon(Icons.person_rounded, size: 24),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}