import 'package:HamroGharSewa/Booking/HistoryPage.dart';
import 'package:HamroGharSewa/Booking/ChatPage.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/providers/booking_provider.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmPage extends StatefulWidget {
  final Map<String, dynamic> providerData;
  final DateTime selectedDateTime;

  const ConfirmPage({
    super.key,
    required this.providerData,
    required this.selectedDateTime,
  });

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _tokenManager = TokenManager();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await _tokenManager.getUserData();
    if (userData != null) {
      setState(() {
        nameController.text = userData['userName'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    addressController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter contact person name';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter phone number';
    }
    final phoneRegex = RegExp(r'^\d{10}$'); // Generic 10 digit check
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Enter valid phone (10 digits)';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter service location';
    }
    if (value.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Confirm Booking",
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      AppColors.primaryBlue.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.12),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.primaryBlue.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryBlue.withOpacity(0.15),
                                AppColors.primaryBlue.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.person_outline_rounded, size: 24, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          "Contact Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatPage(
                                  name: widget.providerData['name'] ?? "Provider",
                                ),
                              ),
                            );
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chat_bubble_outline_rounded,
                                color: AppColors.primaryBlue, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      validator: _validateName,
                      decoration: const InputDecoration(
                        labelText: "Contact Person",
                        hintText: "Enter your full name",
                        prefixIcon: Icon(Icons.person_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: numberController,
                      validator: _validatePhone,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        hintText: "Enter 10 digit number",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: addressController,
                      validator: _validateAddress,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Service Location",
                        hintText: "Enter complete address",
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 32),
            
            Consumer<BookingProvider>(
              builder: (context, provider, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: provider.isLoading
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.primaryBlue, AppColors.primaryPurple],
                          ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: provider.isLoading
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: provider.isLoading
                        ? null
                        : () async {
                            // Validate form
                            if (!_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please fill all fields correctly'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
    
                            // Create Booking using Provider
                            final success = await provider.createBooking(
                              providerId: widget.providerData['id']?.toString() ?? 'provider_demo',
                              serviceId: widget.providerData['serviceCategoryId']?.toString() ?? '1',
                              bookingDate: widget.selectedDateTime,
                              description: 'Service Request from ${nameController.text.trim()}',
                              location: addressController.text.trim(),
                            );
    
                            if (success && context.mounted) {
                              _showSuccessDialog(context);
                            } else if (!success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(provider.error ?? 'Booking failed'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.isLoading ? AppColors.lightGrey : Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
                    ),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 22),
                              SizedBox(width: 10),
                              Text(
                                "CONFIRM BOOKING",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
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
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 10,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withOpacity(0.15),
                      AppColors.success.withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 56,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your service has been successfully booked.\nReview status in your bookings.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMedium,
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.success, Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'View Bookings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

