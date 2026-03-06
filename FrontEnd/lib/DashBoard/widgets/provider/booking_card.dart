import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/models/booking_model.dart';
import 'package:intl/intl.dart';

/// Individual booking card widget
/// Shows booking details with action buttons
class BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onChat;

  const BookingCard({
    Key? key,
    required this.booking,
    this.onAccept,
    this.onReject,
    this.onChat,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine status color and badge
    Color statusColor;
    Color statusBgColor;
    String statusText;

    if (booking.isPending) {
      statusColor = Colors.orange.shade700;
      statusBgColor = Colors.orange.shade50;
      statusText = 'Pending';
    } else if (booking.isAccepted) {
      statusColor = AppColors.primaryBlue;
      statusBgColor = AppColors.primaryBlue.withValues(alpha: 0.1);
      statusText = 'Accepted';
    } else if (booking.isCompleted) {
      statusColor = AppColors.success;
      statusBgColor = AppColors.success.withValues(alpha: 0.1);
      statusText = 'Completed';
    } else if (booking.status == 'IN_PROGRESS') {
      statusColor = const Color(0xFF00BCD4);
      statusBgColor = const Color(0xFF00BCD4).withValues(alpha: 0.1);
      statusText = 'In Progress';
    } else if (booking.isRejected || booking.isCancelled) {
      statusColor = Colors.red;
      statusBgColor = Colors.red.shade50;
      statusText = 'Cancelled';
    } else {
      statusColor = Colors.grey;
      statusBgColor = Colors.grey.shade50;
      statusText = booking.status;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with service name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.serviceName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (booking.description != null && booking.description!.isNotEmpty)
                        Text(
                          booking.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Location and Date
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    booking.location ?? 'No location',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  DateFormat('yyyy-MM-dd').format(booking.bookingDate),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Customer info
            Row(
              children: [
                Text(
                  'Customer: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  booking.userName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            if (booking.isPending && onAccept != null && onReject != null)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              )
            else if (booking.canChat && !booking.isCompleted && !booking.isRejected && !booking.isCancelled && onChat != null)
              ElevatedButton.icon(
                onPressed: onChat,
                icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                label: const Text('Chat with Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
