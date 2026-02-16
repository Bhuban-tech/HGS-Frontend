// lib/widgets/admin_drawer.dart
// This drawer contains admin actions: Dashboard (home), Create Category (navigates to the new screen),
// Manage Providers (could navigate to a dedicated providers screen if needed, but for now assumes dashboard is providers),
// Settings (placeholder), Logout.
// Assumes TokenManager is available for logout.
// Use Navigator to push to other screens (e.g., CreateCategoryScreen).
// Import necessary packages and screens.

import 'package:HamroGharSewa/view/admin/CreateCategoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';// Import the extracted screen
import 'package:HamroGharSewa/services/token_manager.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final _tokenManager = TokenManager();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryBlue, AppColors.primaryBlue.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Admin Controls',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Manage your platform',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.primaryBlue),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context); // Close drawer and stay on current (dashboard)
            },
          ),
          ListTile(
            leading: const Icon(Icons.category, color: AppColors.primaryBlue),
            title: const Text('Create Category'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateCategoryScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.primaryBlue),
            title: const Text('Manage Providers'),
            onTap: () {
              Navigator.pop(context);
              // If you extract providers to a separate screen later, navigate there.
              // For now, assume dashboard handles it.
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: AppColors.primaryBlue),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen (implement if needed)
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              await _tokenManager.logout(context);
            },
          ),
        ],
      ),
    );
  }
}