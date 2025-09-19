import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> bookings = [
    {
      'service': 'Painting',
      'name': 'by Himal',
      'rate': '500/Hour',
      'location': 'Patan',
    },
    {
      'service': 'Carpenter',
      'name': 'by Hari',
      'rate': '500/Hour',
      'location': 'Kathmandu',
    },
    {
      'service': 'Plumbing',
      'name': 'by Ram',
      'rate': '500/Hour',
      'location': 'Bhaktapur',
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredBookings = bookings.where((booking) {
      final query = searchQuery.toLowerCase();
      return booking['service']!.toLowerCase().contains(query) ||
          booking['name']!.toLowerCase().contains(query) ||
          booking['rate']!.toLowerCase().contains(query) ||
          booking['location']!.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3A8EE6),
        title: const Text(
          'Welcome, Sita',
          style: TextStyle(color: Colors.white),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Profile clicked!")),
                );
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  "https://i.pravatar.cc/150?img=47",
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Find the Perfect',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF3A7BFF), Color(0xFF9745F5)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: const Text(
                'Home Service',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search services...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 🔵 Popular Services Icons Row
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(12),
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
            const Text(
              'Popular Services',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (filteredBookings.isEmpty)
              const Text(
                "No services found",
                style: TextStyle(color: Colors.grey),
              ),
            ...filteredBookings
                .map((booking) => BookingCard(booking: booking))
                .toList(),

            const SizedBox(height: 30),
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // 🔧 Service Icon Widget (Icon + Label)
  Widget _buildServiceIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white,
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, String> booking;

  const BookingCard({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.blueAccent,
            blurRadius: 6,
            spreadRadius: 2,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking['service'] ?? '',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 6),
            Text("Name: ${booking['name'] ?? ''}"),
            const SizedBox(height: 4),
            Text("Rate: ${booking['rate'] ?? ''}"),
            const SizedBox(height: 4),
            Text("Location: ${booking['location'] ?? ''}"),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Booking requested for ${booking['service']} (${booking['name']})",
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Book Now",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
