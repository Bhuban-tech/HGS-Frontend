import 'package:HamroGharSewa/DashBoard/User.dart';
import 'package:HamroGharSewa/LandingPage/Hero.dart';
import 'package:HamroGharSewa/ServiceProvider/homePage.dart';
import 'package:HamroGharSewa/view/Login/login_view.dart';
import 'package:HamroGharSewa/view/register/register_view.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';


import 'ServiceProvider/PersonalInfo.dart';

void main() {
  runApp(
    DevicePreview(
      builder: (context) =>  MyApp(),
    ),
  );
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
        '/signup': (context) => const SignUpPage(),
        '/hero': (context) => const HeroPage(),
        '/home': (context) => const UserDashboard(),
        '/personalinfo': (context) => RegisterApp(),
        '/ProviderDashboard ': (context) => ProviderDashboard(),
      },
    );
  }
}