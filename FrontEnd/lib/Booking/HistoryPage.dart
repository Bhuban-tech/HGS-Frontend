import 'package:HamroGharSewa/Booking/ChatPage.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/providers/booking_provider.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:HamroGharSewa/route/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TokenManager _tokenManager = TokenManager();
  bool _isProvider = false;
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserRole();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings();
    });
  }

  Future<void> _loadUserRole() async {
    final userData = await _tokenManager.getUserData();
    if (mounted) {
      setState(() {
        final role = userData?['role']?.toUpperCase() ?? '';
        _isProvider = role == 'SERVICE_PROVIDER' || role == 'PROVIDER';
        _currentUserId = userData?['id'] ?? '';
      });
    }
  }

  Future<void> _fetchBookings() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    if (_isProvider) {
      await provider.fetchProviderBookings();
    } else {
      await provider.fetchUserBookings();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<BookingProvider>(
        builder: (context, provider, _) {
          // ── Get bookings based on role ──────────
          final allBookings = _isProvider 
              ? [...provider.pendingBookings, ...provider.acceptedBookings, ...provider.completedBookings]
              : provider.userBookings;
          
          // ── Split by status using real Booking model getters ──────────
          final upcoming  = allBookings
              .where((b) => b.isPending || b.isAccepted).toList();
          final completed = allBookings
              .where((b) => b.isCompleted).toList();
          final cancelled = allBookings
              .where((b) => b.isRejected || b.isCancelled).toList();

          return Column(
            children: [
              // ── Gradient Header ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 20,
                  bottom: 0,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isProvider ? 'My Service Requests' : 'My Bookings',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${allBookings.length} total ${_isProvider ? "requests" : "bookings"}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TabBar(
                      controller: _tabController,
                      indicatorColor: Colors.white,
                      indicatorWeight: 3,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelColor: Colors.white,
                      unselectedLabelColor:
                      Colors.white.withValues(alpha: 0.55),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13),
                      unselectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                      tabs: [
                        Tab(text: 'Upcoming (${upcoming.length})'),
                        Tab(text: 'Completed (${completed.length})'),
                        Tab(text: 'Cancelled (${cancelled.length})'),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Loading indicator ─────────────────────────────────────
              if (provider.isLoading && provider.userBookings.isEmpty)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(upcoming, 'upcoming'),
                      _buildList(completed, 'completed'),
                      _buildList(cancelled, 'cancelled'),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  int _currentNavIndex = 1; // Bookings tab selected by default

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
        currentIndex: _currentNavIndex,
        onTap: (index) async {
          setState(() => _currentNavIndex = index);
          
          switch (index) {
            case 0:
              // Navigate to correct dashboard based on role
              final dashboardRoute = await _tokenManager.getDashboardRoute();
              
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, dashboardRoute, (route) => false);
              }
              break;
            case 1:
              break; // Already on bookings
            case 2:
              // Show profile menu
              _showProfileMenu();
              break;
          }
        },
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: AppColors.textLight,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
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
              child: Icon(Icons.person_rounded, size: 24),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.person_outline, color: AppColors.primaryBlue),
              title: const Text('Profile Details'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.profile);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.primaryBlue),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit profile page
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile coming soon')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Logout', style: TextStyle(color: AppColors.error)),
              onTap: () async {
                Navigator.pop(context);
                await TokenManager().clearAll();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── List builder ────────────────────────────────────────────────────────
  Widget _buildList(List bookings, String type) {
    if (bookings.isEmpty) return _emptyState(type);
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: bookings.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, i) => _bookingCard(bookings[i]),
    );
  }

  Widget _emptyState(String type) {
    final cfg = {
      'upcoming':  {'icon': Icons.calendar_today_rounded,    'title': 'No Upcoming Bookings',  'sub': 'Book a service and it will appear here.'},
      'completed': {'icon': Icons.check_circle_outline_rounded,'title': 'No Completed Bookings','sub': 'Your completed services will show here.'},
      'cancelled': {'icon': Icons.cancel_outlined,            'title': 'No Cancelled Bookings', 'sub': "You haven't had any cancelled bookings."},
    }[type]!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(cfg['icon'] as IconData,
              size: 72,
              color: AppColors.primaryBlue.withValues(alpha: 0.25)),
          const SizedBox(height: 16),
          Text(cfg['title'] as String,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(cfg['sub'] as String,
              style: const TextStyle(fontSize: 14, color: AppColors.textLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  // ── Booking Card ────────────────────────────────────────────────────────
  Widget _bookingCard(dynamic item) {
    // item is a real Booking object — use its actual fields
    final Color themeColor = _categoryColor(item.serviceName as String);

    // Status badge config
    Color statusColor;
    IconData statusIcon;
    if (item.isPending) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule_rounded;
    } else if (item.isAccepted) {
      statusColor = AppColors.primaryBlue;
      statusIcon = Icons.thumb_up_rounded;
    } else if (item.isCompleted) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_rounded;
    } else {
      // rejected / cancelled
      statusColor = Colors.red;
      statusIcon = Icons.cancel_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColor.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      themeColor.withValues(alpha: 0.15),
                      themeColor.withValues(alpha: 0.08),
                    ]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_categoryIcon(item.serviceName as String),
                      color: themeColor, size: 28),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.serviceName as String,        // ✅ correct field
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.person_outline_rounded,
                            size: 15, color: AppColors.textMedium),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _isProvider 
                                ? 'Request from ${item.userName as String}'
                                : 'Provider: ${item.providerName as String}',
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMedium),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        item.status as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, thickness: 1),
            ),

            // ── Details box ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  // Date
                  Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 16, color: themeColor),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('MMM dd, hh:mm a')
                          .format(item.bookingDate as DateTime), // ✅ correct field
                      style: const TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                    const Spacer(),
                    // Rate chip (from description if available)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                            colors: [themeColor,
                              themeColor.withValues(alpha: 0.7)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  // Location
                  Row(children: [
                    Icon(Icons.location_on_rounded,
                        size: 16, color: themeColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (item.location as String?) ??
                            'No location provided',     // ✅ correct field
                        style: const TextStyle(
                            color: AppColors.textMedium,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                    ),
                  ]),
                  // Description (if any)
                  if ((item.description as String?)?.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.notes_rounded,
                            size: 16, color: themeColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item.description as String, // ✅ correct field
                            style: const TextStyle(
                                color: AppColors.textLight,
                                fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Action Buttons ───────────────────────────────────────────
            Row(children: [
              // Cancel button — only for pending
              if (item.isPending as bool)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _cancelDialog(item.id?.toString() ?? ''),
                    icon: const Icon(Icons.cancel_outlined, size: 16),
                    label: const Text('Cancel', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.4), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    ),
                  ),
                ),

              if (item.isPending as bool) const SizedBox(width: 12),

              // Payment button — only for completed bookings
              if (item.isCompleted as bool)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to payment page
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment feature coming soon!'),
                          backgroundColor: AppColors.primaryBlue,
                        ),
                      );
                    },
                    icon: const Icon(Icons.payment_rounded, size: 18),
                    label: const Text('Pay Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                ),

              if (item.isCompleted as bool) const SizedBox(width: 12),

              // Chat button — show when accepted (chatEnabled OR status is ACCEPTED)
              if (item.canChat as bool || item.isAccepted as bool)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatPage(
                            name: _isProvider 
                                ? item.userName as String 
                                : item.providerName as String,
                            bookingId: item.id?.toString(),
                            userId: _isProvider 
                                ? item.userId 
                                : item.providerId,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                    label: Text(_isProvider ? 'Message Customer' : 'Message Provider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                    ),
                  ),
                )
              else if (item.isPending as bool)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Awaiting Acceptance',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ]),
          ],
        ),
      ),
    );
  }

  void _cancelDialog(String bookingId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cancel Booking',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: AppColors.textDark)),
        content: const Text(
            'Are you sure you want to cancel this booking?',
            style: TextStyle(color: AppColors.textMedium)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep',
                style: TextStyle(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final provider = Provider.of<BookingProvider>(context, listen: false);
              final success = await provider.cancelBooking(bookingId);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success 
                        ? 'Booking cancelled successfully' 
                        : 'Failed to cancel booking',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Color _categoryColor(String s) {
    s = s.toLowerCase();
    if (s.contains('plumb')) return AppColors.serviceBlue;
    if (s.contains('paint')) return AppColors.servicePurple;
    if (s.contains('elect')) return AppColors.serviceOrange;
    if (s.contains('carp'))  return AppColors.serviceTeal;
    if (s.contains('clean')) return AppColors.servicePink;
    if (s.contains('gard'))  return AppColors.serviceGreen;
    return AppColors.primaryBlue;
  }

  IconData _categoryIcon(String s) {
    s = s.toLowerCase();
    if (s.contains('plumb')) return Icons.plumbing_rounded;
    if (s.contains('paint')) return Icons.format_paint_rounded;
    if (s.contains('elect')) return Icons.electrical_services_rounded;
    if (s.contains('carp'))  return Icons.handyman_rounded;
    if (s.contains('clean')) return Icons.cleaning_services_rounded;
    if (s.contains('gard'))  return Icons.yard_rounded;
    return Icons.build_rounded;
  }
}