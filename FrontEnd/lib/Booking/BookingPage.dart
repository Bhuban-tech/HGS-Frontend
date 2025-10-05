import 'package:HamroGharSewa/Booking/Confirm-Booking.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: BookingPage(),
  ));
}

class BookingPage extends StatefulWidget {
  @override
  _BookingPage createState() => _BookingPage();
}

class _BookingPage extends State<BookingPage> {
  int selectedDateIndex = 2;
  int selectedTimeIndex = -1;

  final List<String> dates = ['Thu\n4', 'Fri\n5', 'Sat\n6', 'Sun\n7', 'Mon\n8', 'Tue\n9'];
  final List<String> timeSlots = [
    '8AM - 9AM', '9AM - 10AM', '10AM - 11AM',
    '11AM - 12PM', '12PM - 1PM', '1PM - 2PM',
    '2PM - 3PM', '3PM - 4PM', '4PM - 5PM',
    '5PM - 6PM', '6PM - 7PM', '7PM - 8PM'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          'Plumbing: Tap Installation',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.notifications_none, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF5FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: AssetImage('assets/logo.png'),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Bhuban Bhandari", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, )),
                      SizedBox(height: 4),
                      Text("32 years old • 8 Years Experience"),
                      Text("Kathmandu"),
                      Text("certified by havard"),
                      Text("himal chor"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),


            const Text("Select date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const Text("Please select your desired date."),
            const SizedBox(height: 10),

            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                itemBuilder: (context, index) {
                  bool isSelected = selectedDateIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDateIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          dates[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const Text("Choose a time period", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20)),
            const Text("Be aware that the team will arrive within the selected time frame"),
            const SizedBox(height: 10),

            Expanded(
              child: GridView.builder(
                itemCount: timeSlots.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.5,
                ),
                itemBuilder: (context, index) {
                  bool isSelected = selectedTimeIndex == index;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTimeIndex = index;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        timeSlots[index],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: selectedTimeIndex == -1
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConfirmPage(),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: selectedTimeIndex == -1 ? Colors.blue : Colors.blue,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                "Book Now",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
