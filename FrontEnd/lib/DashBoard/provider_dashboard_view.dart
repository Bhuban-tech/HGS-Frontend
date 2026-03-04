import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/models/booking_model.dart';
import 'package:HamroGharSewa/providers/booking_provider.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:HamroGharSewa/view/ChatPage/chatPage_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({Key? key}) : super(key: key);

  @override
  State<ProviderDashboard> createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  final TokenManager _tokenManager = TokenManager();
  int _selectedIndex = 0;
  String providerName = "Provider";
  String providerEmail = "";
  String providerPhone = "";
  String providerAddress = "Kathmandu, Nepal";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchProviderBookings();
    });
    _loadProviderData();
  }

  Future<void> _loadProviderData() async {
    final userData = await _tokenManager.getUserData();
    if (userData != null && mounted) {
      setState(() {
        providerName = userData['userName'] ?? 'Provider';
        providerEmail = userData['email'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) => setState(() => _selectedIndex = index),
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppColors.primaryBlue,
            unselectedItemColor: AppColors.textLighter,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_rounded),
                activeIcon: Icon(Icons.list_alt_rounded),
                label: 'Requests',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                activeIcon: Icon(Icons.chat_bubble_rounded),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildRequestsTab();
      case 2:
        return _buildChatTab();
      case 3:
        return _buildProfileTab();
      default:
        return _buildHomeTab();
    }
  }

  // --- HOME TAB ---
  Widget _buildHomeTab() {
    return SafeArea(
      child: Consumer<BookingProvider>(
        builder: (context, provider, child) {
          final pending = provider.pendingBookings;
          
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Provider Dashboard',
                                style: TextStyle(
                                  color: AppColors.textLight,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    providerName,
                                    style: const TextStyle(
                                      color: AppColors.textDark,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('⚡', style: TextStyle(fontSize: 24)),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: AppColors.success.withOpacity(0.2)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Online',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Metrics Row
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Total Earnings', 'Rs. 12,450', Icons.account_balance_wallet_rounded, AppColors.primaryBlue)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMetricCard('Jobs Done', '156', Icons.task_alt_rounded, AppColors.success)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildMetricCard('Rating', '4.8', Icons.star_rounded, AppColors.warning)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildMetricCard('Success', '98%', Icons.trending_up_rounded, AppColors.servicePurple)),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Incoming Requests',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: const Text('View All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              if (pending.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('No new requests at the moment'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildIncomingRequestCard(pending[index], provider),
                      childCount: pending.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.lightGrey.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestCard(Booking booking, BookingProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge('Pending', AppColors.warning),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  booking.description ?? 'No description provided',
                  style: const TextStyle(color: AppColors.textMedium, fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildInfoRow(Icons.location_on_rounded, booking.location ?? 'Unknown location'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.calendar_today_rounded, DateFormat('yyyy-MM-dd').format(booking.bookingDate)),
                const SizedBox(height: 8),
                Text(
                  'Customer: ${booking.userName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => provider.acceptBooking(booking.id!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 8),
                        Text('Accept'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => provider.rejectBooking(booking.id!),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: BorderSide(color: AppColors.lightGrey),
                      minimumSize: const Size(0, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: 8),
                        Text('Reject'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- REQUESTS TAB ---
  Widget _buildRequestsTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Requests',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, provider, child) {
                final activeJobs = provider.providerBookings
                    .where((b) => !b.isPending && !b.isRejected)
                    .toList();

                if (activeJobs.isEmpty) {
                  return const Center(child: Text('No active or completed jobs'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: activeJobs.length,
                  itemBuilder: (context, index) => _buildHistoryCard(activeJobs[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Booking booking) {
    Color statusColor;
    String statusText;

    if (booking.isCompleted) {
      statusColor = AppColors.success;
      statusText = 'Completed';
    } else if (booking.isAccepted) {
      statusColor = AppColors.primaryBlue;
      statusText = 'Accepted';
    } else {
      statusColor = AppColors.info;
      statusText = 'In Progress';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  booking.serviceName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(statusText, statusColor),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            booking.description ?? 'Service request',
            style: const TextStyle(color: AppColors.textLight, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_rounded, booking.location ?? 'No location'),
          const SizedBox(height: 4),
          _buildInfoRow(Icons.calendar_today_rounded, DateFormat('yyyy-MM-dd').format(booking.bookingDate)),
          const SizedBox(height: 12),
          Text(
            'Customer: ${booking.userName}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (booking.isAccepted)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(name: booking.userName),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.lightGrey),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Chat with Customer'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- CHAT TAB ---
  Widget _buildChatTab() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: Consumer<BookingProvider>(
              builder: (context, provider, child) {
                final list = provider.providerBookings
                    .where((b) => b.isAccepted || b.isCompleted)
                    .toList();

                if (list.isEmpty) {
                  return const Center(child: Text('No active conversations'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final b = list[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ChatPage(name: b.userName)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryBlue.withOpacity(0.1),
                              child: Text(b.userName[0], style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(b.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text('Tap to message about ${b.serviceName}', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textLighter),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- PROFILE TAB ---
  Widget _buildProfileTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              providerName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const Text(
              'Professional Service Provider',
              style: TextStyle(color: AppColors.textLight, fontSize: 14),
            ),
            const SizedBox(height: 32),
            _buildProfileInfoCard(),
            const SizedBox(height: 24),
            _buildProfileOption(Icons.settings_outlined, 'Account Settings'),
            const SizedBox(height: 12),
            _buildProfileOption(Icons.help_outline_rounded, 'Help Center'),
            const SizedBox(height: 12),
            _buildProfileOption(Icons.logout_rounded, 'Log Out', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.email_outlined, providerEmail),
          const Divider(height: 24),
          _buildInfoItem(Icons.phone_outlined, '+977 9841234567'),
          const Divider(height: 24),
          _buildInfoItem(Icons.location_on_outlined, providerAddress),
          const Divider(height: 24),
          _buildInfoItem(Icons.star_outline_rounded, 'Member since Feb 2026'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textLight),
        const SizedBox(width: 16),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 15, color: AppColors.textDark))),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {bool isDestructive = false}) {
    return GestureDetector(
      onTap: () {
        if (isDestructive) {
          _tokenManager.logout(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? AppColors.error : AppColors.textDark),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDestructive ? AppColors.error : AppColors.textDark,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDestructive ? AppColors.error : AppColors.textLighter),
          ],
        ),
      ),
    );
  }

  // --- HELPERS ---
  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}