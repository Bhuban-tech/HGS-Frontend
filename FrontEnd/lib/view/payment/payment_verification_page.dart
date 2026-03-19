import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/services/payment/payment_service.dart';
import 'package:HamroGharSewa/route/app_routes.dart';

class PaymentVerificationPage extends StatefulWidget {
  final String paymentData;
  final String paymentMethod; 
  final String? bookingId;

  const PaymentVerificationPage({
    Key? key,
    required this.paymentData,
    required this.paymentMethod,
    this.bookingId,
  }) : super(key: key);

  @override
  State<PaymentVerificationPage> createState() => _PaymentVerificationPageState();
}

class _PaymentVerificationPageState extends State<PaymentVerificationPage> {
  late final PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(Dio());
    _verifyPayment();
  }

  Future<void> _verifyPayment() async {
    try {
      Map<String, dynamic> result;

      if (widget.paymentMethod == 'khalti') {
        result = await _paymentService.verifyKhaltiPayment(widget.paymentData);
      } else {
        result = await _paymentService.verifyEsewaPayment(widget.paymentData);
      }

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.history,
          (route) => false,
        );
      }
    } catch (error) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.history,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: const SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 4,
              ),
              SizedBox(height: 32),
              Text(
                'Verifying Payment...',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Please wait while we confirm your payment',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
