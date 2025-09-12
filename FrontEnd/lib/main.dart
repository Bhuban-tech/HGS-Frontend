import 'package:HamroGharSewa/Auth/Login.dart';
import 'package:HamroGharSewa/Auth/SignUp.dart';
import 'package:HamroGharSewa/LandingPage/Landing.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HamroGharSewa',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/landing': (context) => const LandingPage(),
      
      },
    );
  }
}
