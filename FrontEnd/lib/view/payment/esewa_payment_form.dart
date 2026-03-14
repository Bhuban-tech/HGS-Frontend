import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class EsewaPaymentForm extends StatelessWidget {
  final Map<String, dynamic> paymentData;

  const EsewaPaymentForm({
    Key? key,
    required this.paymentData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Immediately try to open payment
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openEsewaPayment(context);
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF60BB46),
        title: const Text(
          'eSewa Payment',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF60BB46),
            ),
            const SizedBox(height: 24),
            const Text(
              'Opening eSewa Payment...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please complete the payment in your browser',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _openEsewaPayment(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF60BB46),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Open Payment Page',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEsewaPayment(BuildContext context) async {
    try {
      // Mobile: Use URL launcher with query parameters
      // Note: eSewa requires POST method, but mobile apps typically use GET with params
      await _openEsewaPaymentMobile();
      
      if (context.mounted) {
        // Show info and close this page
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment page opened. Complete payment and return to app.'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Close this page after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open payment: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _openEsewaPaymentMobile() async {
    // Get endpoint
    final endpoint = paymentData['api_endpoint'] ?? 'https://esewa.com.np/epay/main/v2/form';
    
    // Build query parameters
    final params = <String, String>{};
    paymentData.forEach((key, value) {
      if (key != 'api_endpoint' && value != null) {
        params[key] = value.toString();
      }
    });
    
    // Build URL with query parameters
    final uri = Uri.parse(endpoint).replace(queryParameters: params);
    
    // Launch URL
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch eSewa payment');
    }
  }
}
