import 'package:flutter/material.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: const Color(0xFF3A8EE6),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Find the Perfect',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Home Service',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3A8EE6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      // Navigate to settings
                    },
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _InfoCard(
                    icon: Icons.calendar_today,
                    label: 'Bookings',
                    value: '5',
                    iconColor: Colors.orange,
                  ),
                  _InfoCard(
                    icon: Icons.star,
                    label: 'Rating',
                    value: '4.8',
                    iconColor: Colors.purple,
                  ),
                  _InfoCard(
                    icon: Icons.receipt,
                    label: 'Pending Payments',
                    value: 'Rs. 1200',
                    iconColor: Colors.redAccent,
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Ongoing Services',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              const _ServiceCard(
                title: 'Carpentry Repair',
                description: 'Table repair, expected tomorrow',
                icon: Icons.handyman,
                status: 'In Progress',
              ),

              const SizedBox(height: 12),

              const _ServiceCard(
                title: 'Plumbing Fix',
                description: 'Kitchen sink leakage, booked for 12 May',
                icon: Icons.plumbing,
                status: 'Scheduled',
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to booking page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A8EE6),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Book New Service',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'History',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              const _HistoryTile(
                serviceTitle: 'Cleaning Service',
                date: '05 Jun 2025',
                icon: Icons.cleaning_services,
              ),
              const _HistoryTile(
                serviceTitle: 'Electrical Inspection',
                date: '25 May 2025',
                icon: Icons.electric_bolt,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// InfoCard Widget
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ServiceCard Widget
class _ServiceCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String status;

  const _ServiceCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, size: 32, color: Color(0xFF3A8EE6)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: Text(
          status,
          style: TextStyle(
            color: status == 'In Progress' ? Colors.orange : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// HistoryTile Widget
class _HistoryTile extends StatelessWidget {
  final String serviceTitle;
  final String date;
  final IconData icon;

  const _HistoryTile({
    required this.serviceTitle,
    required this.date,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFF3A8EE6).withOpacity(0.1),
        child: Icon(icon, color: const Color(0xFF3A8EE6)),
      ),
      title: Text(
        serviceTitle,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(date),
    );
  }
}
