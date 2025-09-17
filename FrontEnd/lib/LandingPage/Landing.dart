import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> services = [
      {
        'title': 'Plumbing',
        'description': 'Fix leaks, install fixtures, and more.',
        'icon': Icons.plumbing,
      },
      {
        'title': 'Electrical',
        'description': 'Wiring, lights, and electrical safety.',
        'icon': Icons.electrical_services,
      },
      {
        'title': 'Cleaning',
        'description': 'Home, office, and deep cleaning services.',
        'icon': Icons.cleaning_services,
      },
      {
        'title': 'Carpenter',
        'description': 'Home, office Carpenter services.',
        'icon': Icons.carpenter_outlined,
      },
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),


            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: const [
                  _StatBox(
                    number: '500+',
                    label: 'Service Providers',
                  ),
                  SizedBox(width: 20),
                  _StatBox(
                    number: '1000+',
                    label: 'Happy Customers',
                    color: Colors.green,
                  ),
                  SizedBox(width: 20),
                  _StatBox(
                    number: '4.9',
                    label: 'Average \n Rating',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Popular Services Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Popular Services',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 5),
                  Column(
                    children: [
                      Text(
                        'Professional services for every',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.blue,

                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                        child: Text(
                          'corner of your home',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Service Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: services.map((service) {
                  return Card(
                    elevation: 6,
                    shadowColor: Colors.blue,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            service['icon'],
                            size: 40,
                            color: const Color(0xFF3A8EE6),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Text(
                                  service['description'],
                                  style: const TextStyle(color: Colors.blueGrey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 40),

            // Call to action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Padding(
                    padding: EdgeInsets.fromLTRB(50, 0, 0, 0),
                    child: Center(
                      child: Text(
                        'Ready to Get Started?',
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join thousands of satisfied customers and service providers',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blueGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Footer Cards
            SizedBox(
              height: 140,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    _FooterCard(
                      title: 'Book a Service',
                      description: 'Find and book the best service for you.',
                      icon: Icons.book_online,
                      color: Colors.blue,
                      onTap: () {
                        // Navigate to booking page
                      },
                    ),
                    const SizedBox(width: 15),
                    _FooterCard(
                      title: 'Become a Provider',
                      description: 'Join us and offer your services.',
                      icon: Icons.handshake,
                      color: Colors.green,
                      onTap: () {
                        // Navigate to registration
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String number;
  final String label;
  final Color color;

  const _StatBox({
    required this.number,
    required this.label,
    this.color = Colors.blue,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            number,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _FooterCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shadowColor: Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
