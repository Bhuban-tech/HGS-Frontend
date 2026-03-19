import 'package:HamroGharSewa/DashBoard/AdminDashboard_view.dart';
import 'package:HamroGharSewa/DashBoard/User.dart';
import 'package:HamroGharSewa/DashBoard/provider_dashboard_view.dart';
import 'package:HamroGharSewa/LandingPage/Hero.dart';
import 'package:HamroGharSewa/view/Login/login_view.dart';
import 'package:HamroGharSewa/view/forgetpassword/forgetpassword_view.dart';
import 'package:HamroGharSewa/view/register/register_view.dart';
import 'package:HamroGharSewa/Booking/HistoryPage.dart';
import 'package:HamroGharSewa/Booking/ChatPage.dart';
import 'package:HamroGharSewa/view/admin/AdminProfileScreen.dart';
import 'package:HamroGharSewa/view/profile/edit_profile_screen.dart';
import 'package:HamroGharSewa/view/payment/payment_success_page.dart';
import 'package:HamroGharSewa/view/profile/user_profile_screen.dart';
import 'package:HamroGharSewa/view/profile/edit_profile_screen.dart';
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
  static const String editProfile = '/edit-profile';
  static const String adminProfile = '/admin-profile';
  static const String paymentSuccess = '/payment-success';
  static const String paymentFailure = '/payment-failure';


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
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());
      
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      
      case adminProfile:
        return MaterialPageRoute(builder: (_) => const AdminProfileScreen());
      
      case paymentSuccess:
        return MaterialPageRoute(builder: (_) => const PaymentSuccessPage());
      
      case paymentFailure:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 80),
                  const SizedBox(height: 16),
                  const Text('Payment Failed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Something went wrong during the transaction.'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
        );

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
