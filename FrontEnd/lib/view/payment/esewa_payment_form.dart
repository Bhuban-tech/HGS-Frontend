import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'dart:convert';

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
      // Create form data URL
      final formUrl = _buildEsewaFormUrl();
      
      final uri = Uri.parse(formUrl);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (context.mounted) {
          // Show info and close this page
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment page opened in browser. Complete payment and return to app.'),
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
      } else {
        throw 'Cannot open eSewa payment page';
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

  String _buildEsewaFormUrl() {
    // Build URL with form parameters
    final endpoint = paymentData['api_endpoint'] ?? 'https://esewa.com.np/epay/main/v2/form';
    final params = <String, String>{};
    
    paymentData.forEach((key, value) {
      if (key != 'api_endpoint' && value != null) {
        params[key] = value.toString();
      }
    });
    
    // Create URL with query parameters (eSewa might accept GET for some endpoints)
    final uri = Uri.parse(endpoint).replace(queryParameters: params);
    return uri.toString();
  }
}
