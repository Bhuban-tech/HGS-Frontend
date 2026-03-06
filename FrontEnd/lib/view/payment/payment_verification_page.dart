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
  String _status = 'verifying';
  String _message = 'Verifying payment...';
  Map<String, dynamic>? _paymentDetails;

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
        setState(() {
          _status = 'success';
          _paymentDetails = result;
          _message = 'Payment successful!';
        });

        // Redirect after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            if (widget.bookingId != null) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.history,
                (route) => false,
              );
            } else {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.userDashboard,
                (route) => false,
              );
            }
          }
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _status = 'error';
          _message = error.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_status == 'verifying') ...[
                  CircularProgressIndicator(
                    color: widget.paymentMethod == 'khalti'
                        ? const Color(0xFF5D2E8E)
                        : const Color(0xFF60BB46),
                    strokeWidth: 4,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Verifying Payment...',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please wait while we confirm your payment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (_status == 'success') ...[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.success,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_paymentDetails != null) ...[
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (widget.paymentMethod == 'khalti' && _paymentDetails!['amount'] != null)
                            Text(
                              'Rs. ${(_paymentDetails!['amount'] / 100).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            'Transaction ID: ${_paymentDetails!['transactionId'] ?? _paymentDetails!['referenceId'] ?? 'N/A'}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'Redirecting to bookings...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                if (_status == 'error') ...[
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Payment Failed',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.history,
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: AppColors.primaryBlue),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Go to Bookings'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Try Again'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
