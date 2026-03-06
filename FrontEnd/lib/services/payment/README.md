# Payment Integration - eSewa & Khalti

## Overview
This module implements payment integration for eSewa and Khalti payment gateways in Flutter.

## Files Structure
```
lib/services/payment/
├── payment_service.dart          # API service for payment operations
lib/view/payment/
├── payment_webview.dart          # WebView for payment gateway
└── payment_verification_page.dart # Payment verification UI
```

## Features
- ✅ Khalti payment integration
- ✅ eSewa payment integration
- ✅ Payment initiation
- ✅ Payment verification
- ✅ Success/Failure handling
- ✅ WebView for payment gateway
- ✅ Automatic redirect after payment

## API Endpoints

### Base URL
```
http://localhost:8080/api/payment
```

### Khalti Payment
1. **Initiate**: `POST /khalti/initiate`
2. **Verify**: `POST /khalti/verify`

### eSewa Payment
1. **Initiate**: `POST /esewa/initiate?amount={amount}`
2. **Verify**: `GET /esewa/verify?data={data}`

## Usage

### 1. Add Dependency
Already added to `pubspec.yaml`:
```yaml
webview_flutter: ^4.10.0
```

### 2. Import Services
```dart
import 'package:HamroGharSewa/services/payment/payment_service.dart';
import 'package:HamroGharSewa/view/payment/payment_webview.dart';
import 'package:HamroGharSewa/view/payment/payment_verification_page.dart';
```

### 3. Initialize Service
```dart
final PaymentService _paymentService = PaymentService(ApiClient().dio);
```

### 4. Handle Khalti Payment
```dart
Future<void> _handleKhaltiPayment() async {
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF5D2E8E)),
      ),
    );

    // Initiate payment
    final paymentData = await _paymentService.initiateKhaltiPayment(100);
    
    Navigator.pop(context); // Close loading

    // Open payment webview
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebView(
          paymentUrl: paymentData['payment_url'],
          paymentMethod: 'khalti',
          onSuccess: (pidx) {
            // Handle success
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentVerificationPage(
                  paymentData: pidx,
                  paymentMethod: 'khalti',
                ),
              ),
            );
          },
          onFailure: (error) {
            // Handle failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          },
        ),
      ),
    );
  } catch (error) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $error')),
    );
  }
}
```

### 5. Handle eSewa Payment
```dart
Future<void> _handleEsewaPayment() async {
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF60BB46)),
      ),
    );

    // Initiate payment
    final paymentData = await _paymentService.initiateEsewaPayment(100);
    
    Navigator.pop(context); // Close loading

    // Open payment webview
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentWebView(
          paymentUrl: paymentData['api_endpoint'],
          paymentMethod: 'esewa',
          onSuccess: (data) {
            // Handle success
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentVerificationPage(
                  paymentData: data,
                  paymentMethod: 'esewa',
                ),
              ),
            );
          },
          onFailure: (error) {
            // Handle failure
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error)),
            );
          },
        ),
      ),
    );
  } catch (error) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $error')),
    );
  }
}
```

## Payment Flow

### Khalti Flow
1. User clicks "Pay with Khalti"
2. App calls `initiateKhaltiPayment(amount)`
3. Backend returns `payment_url` and `pidx`
4. App opens WebView with `payment_url`
5. User completes payment on Khalti
6. Khalti redirects to success URL with `pidx`
7. App calls `verifyKhaltiPayment(pidx)`
8. Backend verifies payment
9. App shows success page
10. Redirects to bookings after 3 seconds

### eSewa Flow
1. User clicks "Pay with eSewa"
2. App calls `initiateEsewaPayment(amount)`
3. Backend returns `api_endpoint` and `formData`
4. App opens WebView with payment form
5. User completes payment on eSewa
6. eSewa redirects to success URL with `data`
7. App calls `verifyEsewaPayment(data)`
8. Backend verifies payment
9. App shows success page
10. Redirects to bookings after 3 seconds

## Test Credentials

### Khalti Test
- Use Khalti test environment
- Any test card works in test mode
- Test URL: `https://test-pay.khalti.com/`

### eSewa Test
- Use eSewa test environment
- Test credentials provided by eSewa
- Test URL: `https://rc-epay.esewa.com.np/`

## Return URLs
Configured in backend:
- Success: `http://localhost:3000/payment-success`
- Failure: `http://localhost:3000/payment-failure`

## Error Handling
- Network errors
- Payment cancellation
- Verification failures
- Timeout errors

## Security
- JWT token required for all API calls
- Payment data encrypted
- Secure WebView implementation
- No sensitive data stored locally

## Testing
1. Run `flutter pub get` to install dependencies
2. Ensure backend is running on `http://localhost:8080`
3. Click eSewa or Khalti card in User Dashboard
4. Complete test payment
5. Verify payment success page appears
6. Check booking history for payment status

## Notes
- Test amount is Rs. 100 (hardcoded for testing)
- Change amount in production based on booking
- WebView requires internet connection
- Payment verification is automatic
- Success page auto-redirects after 3 seconds

## Future Enhancements
- [ ] Add payment history
- [ ] Support multiple currencies
- [ ] Add refund functionality
- [ ] Implement payment receipts
- [ ] Add payment analytics
