import 'package:HamroGharSewa/DashBoard/AdminDashboard_view.dart';
import 'package:HamroGharSewa/DashBoard/User.dart';
import 'package:HamroGharSewa/DashBoard/provider_dashboard_view.dart';
import 'package:HamroGharSewa/LandingPage/Hero.dart';
import 'package:HamroGharSewa/view/Login/login_view.dart';
import 'package:HamroGharSewa/view/forgetpassword/forgetpassword_view.dart';
import 'package:HamroGharSewa/view/register/register_view.dart';
import 'package:HamroGharSewa/Booking/HistoryPage.dart';
import 'package:HamroGharSewa/Booking/ChatPage.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String userDashboard = '/user-dashboard';
  static const String providerDashboard = '/provider-dashboard';
  static const String adminDashboard = '/admin-dashboard';
  static const String history = '/history';
  static const String chat = '/chat';
  static const String profile = '/profile';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute(builder: (_) => const HeroPage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signup:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      
      case userDashboard:
        return MaterialPageRoute(builder: (_) => const UserDashboard());
      
      case providerDashboard:
        return MaterialPageRoute(builder: (_) => const ProviderDashboard());

      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const ServiceAdminApp());
      
      case history:
        // History page requires specific data? usually not.
        return MaterialPageRoute(builder: (_) => const HistoryPage());
        
      case chat:
        // Chat page usually needs a name or bookingId, adding a placeholder for now
        return MaterialPageRoute(builder: (_) => const ChatPage(name: "Support Chat"));

      case profile:
        // Assuming a Profile page would exist or navigate back to UserDashboard for now
        return MaterialPageRoute(builder: (_) => const UserDashboard());
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
