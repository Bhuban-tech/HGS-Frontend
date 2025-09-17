import 'package:flutter/material.dart';

class ServiceProviderCard extends StatelessWidget {
  const ServiceProviderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Sita's Electrical Works",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.star_border, color: Colors.green, size: 18),
                      SizedBox(width: 4),
                      Text(
                        '4.8',
                        style: TextStyle(color: Colors.green),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 8),

            // Location
            Row(
              children: const [
                Icon(Icons.location_on, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Lalitpur',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Row(
              children: const [
                Icon(Icons.attach_money, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'NPR 900/hour',
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),

            const SizedBox(height: 12),


            const Text(
              'Services:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: const [
                Chip(
                  label: Text('Electrical'),
                  backgroundColor: Color(0xFFF1F1F1),
                ),
                Chip(
                  label: Text('Wiring'),
                  backgroundColor: Color(0xFFF1F1F1),
                ),
                Chip(
                  label: Text('Appliance Repair'),
                  backgroundColor: Color(0xFFF1F1F1),
                ),
              ],
            ),

            const SizedBox(height: 12),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '6 years exp.',
                  style: TextStyle(color: Colors.black87),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
