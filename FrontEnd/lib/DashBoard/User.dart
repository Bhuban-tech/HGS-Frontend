import 'package:flutter/material.dart';
import 'package:HamroGharSewa/view/booking/bookingPage_view.dart';

class BecomeProviderScreen extends StatelessWidget {
  const BecomeProviderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Become a Service Provider')),
      body: const Center(
        child: Text(
          'Provider Registration Form\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserDashboard(userName: "Sita"), // Pass dynamic name here in real app
  ));
}

class UserDashboard extends StatefulWidget {
  final String userName; // Will come from auth (e.g., login)

  const UserDashboard({super.key, required this.userName});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _searchController = TextEditingController();
  String searchQuery = "";

  final List<Map<String, dynamic>> bookings = [
    {
      'service': 'Painting',
      'name': 'by Himal',
      'rate': 'NPR 500/Hour',
      'location': 'Patan',
      'icon': Icons.format_paint,
    },
    {
      'service': 'Carpenter',
      'name': 'by Hari',
      'rate': 'NPR 600/Hour',
      'location': 'Kathmandu',
      'icon': Icons.handyman,
    },
    {
      'service': 'Plumbing',
      'name': 'by Ram',
      'rate': 'NPR 550/Hour',
      'location': 'Bhaktapur',
      'icon': Icons.plumbing,
    },
    {
      'service': 'Electrician',
      'name': 'by Shyam',
      'rate': 'NPR 700/Hour',
      'location': 'Lalitpur',
      'icon': Icons.electrical_services,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement actual logout (clear token, navigate to login)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Logged out successfully")),
              );
              // Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = bookings.where((booking) {
      final query = searchQuery.toLowerCase();
      return booking['service']!.toLowerCase().contains(query) ||
          booking['name']!.toLowerCase().contains(query) ||
          booking['location']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A8EE6),
        elevation: 0,
        title: Text(
          'Welcome, ${widget.userName}',
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog();
                }
              },
              icon: const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF3A8EE6)),
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Logout"),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find the Perfect',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF3A7BFF), Color(0xFF9745F5)],
              ).createShader(bounds),
              child: const Text(
                'Home Service',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search for services, location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => searchQuery = "");
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            const SizedBox(height: 30),

            // Quick Service Icons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildServiceIcon(Icons.plumbing, "Plumber"),
                  _buildServiceIcon(Icons.format_paint, "Painting"),
                  _buildServiceIcon(Icons.electrical_services, "Electrician"),
                  _buildServiceIcon(Icons.handyman, "Carpenter"),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Popular Services
            const Text(
              'Popular Services',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (filteredBookings.isEmpty)
              const Center(
                child: Text(
                  "No services found matching your search",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              )
            else
              ...filteredBookings.map((booking) => BookingCard(
                booking: booking,
                onBook: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) =>  BookingPage()),
                  );
                },
              )),

            const SizedBox(height: 40),

            // Become Provider Button with Gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3A8EE6), Color(0xFF6A4CFF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BecomeProviderScreen()),
                  );
                },
                icon: const Icon(Icons.work, size: 28),
                label: const Text(
                  "Become a Service Provider",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
            ],
          ),
          child: Icon(icon, size: 32, color: const Color(0xFF3A8EE6)),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onBook;

  const BookingCard({required this.booking, required this.onBook, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade50,
              child: Icon(booking['icon'], size: 32, color: const Color(0xFF3A8EE6)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['service'],
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(booking['name'], style: const TextStyle(color: Colors.grey)),
                  Text(booking['location'], style: const TextStyle(color: Colors.grey)),
                  Text(
                    booking['rate'],
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: onBook,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A8EE6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text("Book", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}