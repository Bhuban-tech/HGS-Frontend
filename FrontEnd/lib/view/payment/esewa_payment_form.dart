import 'dart:convert';
import 'package:flutter/foundation.dart'; // To check for kIsWeb
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js; // Needed for Web POST redirection

class EsewaPaymentForm extends StatefulWidget {
  final Map<String, dynamic> paymentData;

  const EsewaPaymentForm({
    Key? key,
    required this.paymentData,
  }) : super(key: key);

  @override
  State<EsewaPaymentForm> createState() => _EsewaPaymentFormState();
}

class _EsewaPaymentFormState extends State<EsewaPaymentForm> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _initiateWebPayment();
    } else {
      _initializeWebView();
    }
  }

  void _initiateWebPayment() {
    final endpoint = widget.paymentData['api_endpoint'] ?? 'https://rc-epay.esewa.com.np/api/epay/main/v2/form';
    final Map<String, dynamic> formData = widget.paymentData['formData'] as Map<String, dynamic>? ?? widget.paymentData;

    final StringBuffer jsCode = StringBuffer();
    jsCode.writeln('var form = document.createElement("form");');
    jsCode.writeln('form.setAttribute("method", "post");');
    jsCode.writeln('form.setAttribute("action", "$endpoint");');

    formData.forEach((key, value) {
      if (key != 'api_endpoint' && value != null) {
        final sanitizedValue = value.toString().replaceAll("'", "\\'");
        jsCode.writeln('var field$key = document.createElement("input");');
        jsCode.writeln('field$key.setAttribute("type", "hidden");');
        jsCode.writeln('field$key.setAttribute("name", "$key");');
        jsCode.writeln('field$key.setAttribute("value", "$sanitizedValue");');
        jsCode.writeln('form.appendChild(field$key);');
      }
    });

    jsCode.writeln('document.body.appendChild(form);');
    jsCode.writeln('form.submit();');

    try {
      js.context.callMethod('eval', [jsCode.toString()]);
    } catch (e) {
      print('🔴 Web Redirection Error: $e');
    }
  }

  void _initializeWebView() {
    final endpoint = widget.paymentData['api_endpoint'] ?? 'https://rc-epay.esewa.com.np/api/epay/main/v2/form';
    final Map<String, dynamic> formData = widget.paymentData['formData'] as Map<String, dynamic>? ?? widget.paymentData;

    final String formHtml = _generateEsewaFormHtml(endpoint, formData);
    final String contentBase64 = base64Encode(const Utf8Encoder().convert(formHtml));

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) => setState(() => _isLoading = true),
          onPageFinished: (String url) => setState(() => _isLoading = false),
          onWebResourceError: (WebResourceError error) => print('🔴 WebView error: ${error.description}'),
        ),
      )
      ..loadRequest(Uri.parse('data:text/html;base64,$contentBase64'));
  }

  String _generateEsewaFormHtml(String endpoint, Map<String, dynamic> data) {
    final StringBuffer formFields = StringBuffer();
    
    data.forEach((key, value) {
      if (key != 'api_endpoint' && value != null) {
        formFields.writeln('<input type="hidden" name="$key" value="$value">');
      }
    });

    return '''
      <!DOCTYPE html>
      <html>
        <head>
          <title>eSewa Payment</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body onload="document.forms[0].submit()">
          <div style="text-align: center; margin-top: 50px; font-family: sans-serif;">
            <div class="spinner"></div>
            <p>Redirecting to eSewa...</p>
            <form action="$endpoint" method="POST">
              $formFields
            </form>
          </div>
          <style>
            .spinner {
              border: 4px solid #f3f3f3;
              border-top: 4px solid #60BB46;
              border-radius: 50%;
              width: 40px;
              height: 40px;
              animation: spin 1s linear infinite;
              margin: 0 auto 20px;
            }
            @keyframes spin {
              0% { transform: rotate(0deg); }
              100% { transform: rotate(360deg); }
            }
          </style>
        </body>
      </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF60BB46),
        title: const Text(
          'eSewa Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: kIsWeb 
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF60BB46)),
                SizedBox(height: 16),
                Text('Processing payment redirection...'),
              ],
            ),
          )
        : Stack(
            children: [
              if (_controller != null) WebViewWidget(controller: _controller!),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF60BB46),
                  ),
                ),
            ],
          ),
    );
  }
}
