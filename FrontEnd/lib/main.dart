
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
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'services/auth_service.dart';
import 'constants/api_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AuthService().initialize();
  final isLoggedIn = await TokenManager().isLoggedIn();
  
  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

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
        builder: DevicePreview.appBuilder,
        title: 'HamroGharSewa',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.landing,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}