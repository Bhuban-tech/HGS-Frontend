import 'package:flutter/material.dart';
import 'package:HamroGharSewa/Booking/ChatPage.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int selectedIndex = 0;

  final List<Map<String, String>> addresses = [
    {
      "name": "Bhuban Bhandari (Home)",
      "address": "chabahil 3\nnear kl tower",
      "phone": "9703497318",
    },
    {
      "name": "Bhuban Bhandaris",
      "address": "chabahil\nchabahil",
      "phone": "9703497318",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Select Address"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final item = addresses[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selectedIndex == index
                    ? Colors.deepPurple
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Radio<int>(
                        value: index,
                        groupValue: selectedIndex,
                        activeColor: Colors.deepPurple,
                        onChanged: (value) {
                          setState(() {
                            selectedIndex = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Text(
                          item["name"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item["address"]!,
                    style:
                    const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item["phone"]!,
                    style: const TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          "cancel",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Chat button navigates to ChatPage with name
                      TextButton.icon(
                        icon: const Icon(Icons.chat, color: Colors.deepPurple),
                        label: const Text(
                          "Chat",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                name: item["name"]!,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
