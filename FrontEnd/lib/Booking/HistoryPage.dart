import 'package:HamroGharSewa/Booking/ChatPage.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/providers/booking_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingProvider>(context, listen: false).fetchUserBookings();
    });
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
          // ── Split by status using real Booking model getters ──────────
          final upcoming  = provider.userBookings
              .where((b) => b.isPending || b.isAccepted).toList();
          final completed = provider.userBookings
              .where((b) => b.isCompleted).toList();
          final cancelled = provider.userBookings
              .where((b) => b.isRejected).toList();

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
                    const Text(
                      'My Bookings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.userBookings.length} total bookings',
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
                            item.providerName as String,   // ✅ correct field
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
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(
                          color: Colors.red.withValues(alpha: 0.4), width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),

              if (item.isPending as bool) const SizedBox(width: 12),

              // Chat button — only if accepted or completed (canChat)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: (item.canChat as bool)
                      ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          name: item.providerName as String,
                        ),
                      ),
                    );
                  }
                      : null, // disabled if not accepted yet
                  icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                  label: Text(
                    (item.canChat as bool) ? 'Chat' : 'Awaiting Acceptance',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[200],
                    disabledForegroundColor: AppColors.textLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
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
            onPressed: () {
              Navigator.pop(context);
              // Call your real API cancel here if needed
              // Provider.of<BookingProvider>(context, listen: false).rejectBooking(bookingId);
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