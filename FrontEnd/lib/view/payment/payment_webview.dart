import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'dart:io' show Platform;

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final String paymentMethod; // 'khalti' or 'esewa'
  final Function(String) onSuccess;
  final Function(String) onFailure;

  const PaymentWebView({
    Key? key,
    required this.paymentUrl,
    required this.paymentMethod,
    required this.onSuccess,
    required this.onFailure,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() => _isLoading = true);
              _checkForCallback(url);
            },
            onPageFinished: (String url) {
              setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              widget.onFailure('Payment failed: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paymentUrl));
    } catch (e) {
      print('WebView initialization error: $e');
      widget.onFailure('WebView initialization failed. Please restart the app.');
    }
  }

  void _checkForCallback(String url) {
    // Check for success callback
    if (url.contains('payment-success')) {
      final uri = Uri.parse(url);
      
      if (widget.paymentMethod == 'khalti') {
        final pidx = uri.queryParameters['pidx'];
        if (pidx != null) {
          widget.onSuccess(pidx);
        }
      } else if (widget.paymentMethod == 'esewa') {
        final data = uri.queryParameters['data'];
        if (data != null) {
          widget.onSuccess(data);
        }
      }
    }
    
    // Check for failure callback
    if (url.contains('payment-failure')) {
      widget.onFailure('Payment was cancelled or failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.paymentMethod == 'khalti' 
            ? const Color(0xFF5D2E8E) 
            : const Color(0xFF60BB46),
        title: Text(
          widget.paymentMethod == 'khalti' ? 'Khalti Payment' : 'eSewa Payment',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            widget.onFailure('Payment cancelled by user');
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: widget.paymentMethod == 'khalti'
                          ? const Color(0xFF5D2E8E)
                          : const Color(0xFF60BB46),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Loading payment page...',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
