import 'package:flutter/material.dart';


class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProviderDashboardState createState() => _ProviderDashboardState();
}

class _ProviderDashboardState extends State<ProviderDashboard> {
  // Sample Data
  List<Map<String, dynamic>> bookings = [
    {
      'id': '1',
      'customerName': 'Ram Sharma',
      'customerPhone': '9841234567',
      'service': 'Plumbing',
      'date': '2024-12-15',
      'time': '10:00 AM',
      'location': 'Kathmandu',
      'price': 'Rs. 1500',
      'status': 'pending',
    },
    {
      'id': '2',
      'customerName': 'Sita Thapa',
      'customerPhone': '9851234568',
      'service': 'Electrical',
      'date': '2024-12-16',
      'time': '2:00 PM',
      'location': 'Lalitpur',
      'price': 'Rs. 2000',
      'status': 'accepted',
    },
    {
      'id': '3',
      'customerName': 'Hari Prasad',
      'customerPhone': '9861234569',
      'service': 'Cleaning',
      'date': '2024-12-14',
      'time': '9:00 AM',
      'location': 'Bhaktapur',
      'price': 'Rs. 1200',
      'status': 'completed',
    },
    {
      'id': '4',
      'customerName': 'Gita Rai',
      'customerPhone': '9871234570',
      'service': 'Plumbing',
      'date': '2024-12-17',
      'time': '11:00 AM',
      'location': 'Kathmandu',
      'price': 'Rs. 1800',
      'status': 'pending',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildDashboardContent(),
    );
  }

  // AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'H',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hamroghar Sewa',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Service Provider Dashboard',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_outlined, color: Colors.black),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.settings_outlined, color: Colors.black),
          onPressed: () {},
        ),
        Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.blue,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // Dashboard Content
  Widget _buildDashboardContent() {
    // Calculate stats
    final pendingCount = bookings.where((b) => b['status'] == 'pending').length;
    final acceptedCount = bookings.where((b) => b['status'] == 'accepted').length;
    final completedCount = bookings.where((b) => b['status'] == 'completed').length;

    final totalEarnings = bookings
        .where((b) => b['status'] == 'completed')
        .fold(0, (sum, b) {
      final price = b['price'].toString().replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (int.tryParse(price) ?? 0);
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Demo Banner
          _buildDemoBanner(),
          SizedBox(height: 20),

          // Stats Cards
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                'Total Earnings',
                'Rs. ${totalEarnings.toString()}',
                Icons.attach_money,
                [Colors.blue[400]!, Colors.blue[600]!],
              ),
              _buildStatCard(
                'Completed',
                completedCount.toString(),
                Icons.check_circle,
                [Colors.green[400]!, Colors.green[600]!],
              ),
              _buildStatCard(
                'Pending',
                pendingCount.toString(),
                Icons.access_time,
                [Colors.orange[400]!, Colors.orange[600]!],
              ),
              _buildStatCard(
                'Avg Rating',
                '4.7 ⭐',
                Icons.star,
                [Colors.purple[400]!, Colors.purple[600]!],
              ),
            ],
          ),
          SizedBox(height: 20),

          // Recent Bookings
          _buildRecentBookings(pendingCount, acceptedCount),
        ],
      ),
    );
  }

  // Demo Banner
  Widget _buildDemoBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[500]!, Colors.pink[500]!],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.touch_app, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16),

        ],
      ),
    );
  }

  // Stat Card
  Widget _buildStatCard(String title, String value, IconData icon, List<Color> colors) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      value,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 32),
            ],
          ),
        ],
      ),
    );
  }

  // Recent Bookings Section
  Widget _buildRecentBookings(int pendingCount, int acceptedCount) {
    final visibleBookings = bookings.where((b) => b['status'] != 'rejected').toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Bookings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    _buildBadge('$pendingCount Pending', Colors.yellow),
                    SizedBox(width: 8),
                    _buildBadge('$acceptedCount Accepted', Colors.blue),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),

          // Bookings List
          if (visibleBookings.isEmpty)
            Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                  SizedBox(height: 16),
                  Text(
                    'No bookings yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: visibleBookings.length,
              separatorBuilder: (context, index) => Divider(height: 1),
              itemBuilder: (context, index) {
                final booking = visibleBookings[index];
                return _buildBookingCard(booking);
              },
            ),
        ],
      ),
    );
  }

  // Badge Widget
  Widget _buildBadge(String text, MaterialColor color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color[800],
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Booking Card
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final status = booking['status'] ?? 'pending';
    final customerName = booking['customerName'] ?? 'Unknown';
    final customerPhone = booking['customerPhone'] ?? '';
    final service = booking['service'] ?? '';
    final date = booking['date'] ?? '';
    final time = booking['time'] ?? '';
    final location = booking['location'] ?? '';
    final price = booking['price'] ?? '';

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Info & Status
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.blue[100],
                child: Text(
                  customerName.isNotEmpty ? customerName[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      customerPhone,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          SizedBox(height: 12),
          Divider(),
          SizedBox(height: 12),

          // Booking Details
          _buildInfoRow(Icons.work_outline, 'Service', service),
          _buildInfoRow(Icons.calendar_today, 'Date & Time', '$date at $time'),
          _buildInfoRow(Icons.location_on, 'Location', location),
          _buildInfoRow(Icons.attach_money, 'Price', price),
          SizedBox(height: 16),

          // Action Buttons
          _buildActionButtons(booking),
        ],
      ),
    );
  }

  // Status Badge
  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.yellow[700]!;
        label = 'Pending';
        break;
      case 'accepted':
        color = Colors.blue[700]!;
        label = 'Accepted';
        break;
      case 'completed':
        color = Colors.green[700]!;
        label = 'Completed';
        break;
      default:
        color = Colors.grey[700]!;
        label = 'Unknown';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Info Row
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Action Buttons
  Widget _buildActionButtons(Map<String, dynamic> booking) {
    final status = booking['status'];
    final bookingId = booking['id'];

    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleAcceptBooking(bookingId, booking),
              icon: Icon(Icons.check_circle),
              label: Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _handleRejectBooking(bookingId, booking),
              icon: Icon(Icons.cancel),
              label: Text('Reject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'accepted') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handleCompleteBooking(bookingId, booking),
          icon: Icon(Icons.check_circle_outline),
          label: Text('Mark Complete'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    } else {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            _showSnackbar('View booking details', Colors.grey[700]!);
          },
          child: Text('View Details'),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }
  }

  // Handle Accept Booking
  void _handleAcceptBooking(String bookingId, Map<String, dynamic> booking) async {
    final confirmed = await _showConfirmDialog(
      'Accept Booking?',
      booking,
      'By accepting, you commit to providing service at the scheduled time.',
      Colors.green,
    );

    if (confirmed == true) {
      setState(() {
        final index = bookings.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          bookings[index]['status'] = 'accepted';
        }
      });
      _showSnackbar('✅ Booking accepted! Customer will be notified.', Colors.green);
    }
  }

  // Handle Reject Booking
  void _handleRejectBooking(String bookingId, Map<String, dynamic> booking) async {
    final confirmed = await _showConfirmDialog(
      'Reject Booking?',
      booking,
      'The customer will be notified to find another provider.',
      Colors.red,
    );

    if (confirmed == true) {
      setState(() {
        final index = bookings.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          bookings[index]['status'] = 'rejected';
        }
      });
      _showSnackbar('ℹ️ Booking rejected. Customer will be notified.', Colors.blue);
    }
  }

  // Handle Complete Booking
  void _handleCompleteBooking(String bookingId, Map<String, dynamic> booking) async {
    final confirmed = await _showConfirmDialog(
      'Complete Booking?',
      booking,
      'Payment will be processed and added to your earnings.',
      Colors.blue,
    );

    if (confirmed == true) {
      setState(() {
        final index = bookings.indexWhere((b) => b['id'] == bookingId);
        if (index != -1) {
          bookings[index]['status'] = 'completed';
        }
      });
      _showSnackbar('✅ Booking completed! Payment will be processed.', Colors.green);
    }
  }

  // Confirmation Dialog
  Future<bool?> _showConfirmDialog(
      String title,
      Map<String, dynamic> booking,
      String message,
      Color color,
      ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Customer:', booking['customerName']),
                  _buildDetailRow('Service:', booking['service']),
                  _buildDetailRow('Date:', '${booking['date']} at ${booking['time']}'),
                  _buildDetailRow('Location:', booking['location']),
                  _buildDetailRow('Price:', booking['price']),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
            ),
            child: Text(
              title.split(' ')[0],
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Detail Row in Dialog
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Show Snackbar
  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}