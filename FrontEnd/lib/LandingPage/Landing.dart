import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

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
        'description': 'Home, office carpenter services.',
        'icon': Icons.carpenter_outlined,
      },
    ];

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
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
                label: 'Average Rating',
                color: Colors.purple,
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Popular Services',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Professional services for every corner of your home',
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

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
                        service['icon'] as IconData,
                        size: 40,
                        color: const Color(0xFF3A8EE6),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service['title'] as String,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              service['description'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blueGrey,
                              ),
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

        SizedBox(
          height: 140,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // You can add footer cards here
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
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
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color,
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
