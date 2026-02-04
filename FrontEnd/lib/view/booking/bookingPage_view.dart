import 'package:HamroGharSewa/Booking/Confirm-Booking.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  int selectedDateIndex = 0;
  int selectedTimeIndex = -1;

  final List<Map<String, String>> dates = [
    {'day': 'Thu', 'date': '4'},
    {'day': 'Fri', 'date': '5'},
    {'day': 'Sat', 'date': '6'},
    {'day': 'Sun', 'date': '7'},
    {'day': 'Mon', 'date': '8'},
    {'day': 'Tue', 'date': '9'},
  ];

  final List<String> timeSlots = [
    '08:00 AM', '09:00 AM', '10:00 AM',
    '11:00 AM', '12:00 PM', '01:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM',
    '05:00 PM', '06:00 PM', '07:00 PM'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Provider Profile Card
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppColors.primaryBlue.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.12),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                      border: Border.all(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'provider_image',
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primaryBlue.withValues(alpha: 0.15),
                                  AppColors.primaryPurple.withValues(alpha: 0.15),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.person_rounded, size: 45, color: AppColors.primaryBlue),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primaryBlue.withValues(alpha: 0.15),
                                      AppColors.primaryBlue.withValues(alpha: 0.08),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded, size: 13, color: AppColors.primaryBlue),
                                    const SizedBox(width: 5),
                                    const Text(
                                      "Plumbing Expert",
                                      style: TextStyle(
                                        color: AppColors.primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Bhuban Bhandari",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.warning.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                                        const SizedBox(width: 4),
                                        const Text(
                                          "4.8",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                            color: AppColors.textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "(120 reviews)",
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded, color: AppColors.primaryBlue, size: 15),
                                  const SizedBox(width: 4),
                                  Text(
                                    "Kathmandu, Nepal",
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Calendar Section
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue.withValues(alpha: 0.15),
                              AppColors.primaryBlue.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.calendar_month_rounded, size: 20, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Select Date",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(dates.length, (index) {
                        final isSelected = selectedDateIndex == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedDateIndex = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: const EdgeInsets.only(right: 14),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primaryBlue.withValues(alpha: 0.35),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      )
                                    ]
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                              border: Border.all(
                                color: isSelected ? Colors.transparent : AppColors.lightGrey,
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  dates[index]['day']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textMedium,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dates[index]['date']!,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textDark,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Time Selection
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue.withValues(alpha: 0.15),
                              AppColors.primaryBlue.withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.access_time_rounded, size: 20, color: AppColors.primaryBlue),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Available Time Slots",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: timeSlots.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (context, index) {
                      final isSelected = selectedTimeIndex == index;
                      return GestureDetector(
                        onTap: () => setState(() => selectedTimeIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                                  )
                                : null,
                            color: isSelected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : AppColors.lightGrey,
                              width: 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    )
                                  ]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isSelected)
                                const Padding(
                                  padding: EdgeInsets.only(right: 6),
                                  child: Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                                ),
                              Text(
                                timeSlots[index],
                                style: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.textDark,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(34),
                topRight: Radius.circular(34),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 25,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  gradient: selectedTimeIndex == -1
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                        ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: selectedTimeIndex == -1
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                ),
                child: ElevatedButton(
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
                    backgroundColor: selectedTimeIndex == -1 ? AppColors.lightGrey : Colors.transparent,
                    foregroundColor: selectedTimeIndex == -1 ? AppColors.textLight : Colors.white,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedTimeIndex == -1 ? "Select a time slot" : "Continue to Booking",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (selectedTimeIndex != -1) const SizedBox(width: 10),
                      if (selectedTimeIndex != -1) const Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
