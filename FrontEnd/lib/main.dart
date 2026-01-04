import 'package:HamroGharSewa/route/app_routes.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'services/auth_service.dart';

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
    return MaterialApp(
      title: 'HamroGharSewa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      initialRoute: AppRoutes.login,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}