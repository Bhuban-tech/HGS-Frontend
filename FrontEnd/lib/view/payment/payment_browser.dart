import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';

class PaymentBrowser {
  /// Open payment URL in external browser
  static Future<void> openPaymentUrl({
    required BuildContext context,
    required String paymentUrl,
    required String paymentMethod,
  }) async {
    try {
      final uri = Uri.parse(paymentUrl);
      
      // Check if URL can be launched
      if (await canLaunchUrl(uri)) {
        // Open in external browser
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched) {
          throw 'Could not launch payment URL';
        }
      } else {
        throw 'Cannot open payment URL';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open payment page: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
