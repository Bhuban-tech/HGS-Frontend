import 'package:HamroGharSewa/constants/app_theme.dart';
import 'package:HamroGharSewa/route/app_routes.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:HamroGharSewa/services/booking_service.dart';
import 'package:HamroGharSewa/services/chat_service.dart';
import 'package:HamroGharSewa/services/service_api_service.dart';
import 'package:HamroGharSewa/providers/booking_provider.dart';
import 'package:HamroGharSewa/providers/chat_provider.dart';
import 'package:HamroGharSewa/providers/service_provider.dart' as sp;
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Register platform implementation for mobile WebViews
  if (WebViewPlatform.instance == null) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      WebViewPlatform.instance = AndroidWebViewPlatform();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      WebViewPlatform.instance = WebKitWebViewPlatform();
    }
  }

  AuthService().initialize();
  final isLoggedIn = await TokenManager().isLoggedIn();

  // Detect if app was opened via a payment redirect (e.g. from eSewa)
  String startRoute = AppRoutes.landing;
  if (kIsWeb) {
    final uri = Uri.base;
    final path = uri.path;
    if (path.contains('payment-success')) {
      startRoute = AppRoutes.paymentSuccess;
    } else if (path.contains('payment-failure')) {
      startRoute = AppRoutes.paymentFailure;
    } else if (isLoggedIn) {
      startRoute = AppRoutes.landing;
    }
  }
  
  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => MyApp(isLoggedIn: isLoggedIn, startRoute: startRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final String startRoute;
  const MyApp({Key? key, required this.isLoggedIn, required this.startRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize Dio instance
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Initialize services
    final bookingService = BookingService(dio);
    final chatService = ChatService(dio);
    final serviceApiService = ServiceApiService(dio);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookingProvider(bookingService),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(chatService),
        ),
        ChangeNotifierProvider(
          create: (_) => sp.ServiceProvider(serviceApiService),
        ),
      ],
      child: MaterialApp(
        useInheritedMediaQuery: true,
        locale: DevicePreview.locale(context),
        builder: (context, child) => DevicePreview.appBuilder(
          context,
          ScrollConfiguration(
            behavior: _PointerScrollBehavior(),
            child: child!,
          ),
        ),
        title: 'HamroGharSewa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: startRoute,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}

/// Makes GestureDetector / InkWell show pointer cursor on web
class _PointerScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
