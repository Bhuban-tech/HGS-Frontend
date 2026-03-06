import 'package:HamroGharSewa/view/admin/CreateCategoryScreen.dart';
import 'package:HamroGharSewa/view/admin/ManageUsersScreen.dart';
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

import 'AdminProfileScreen.dart';
import 'ManageProvidersScreen.dart';

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
                  'HGS',
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
              Navigator.pop(context);
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageProvidersScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.manage_accounts, color: AppColors.primaryBlue),
            title: const Text('Manage Users'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primaryBlue),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminProfileScreen()),
              );
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
          // In AdminDrawer — add this ListTile before Dashboard

        ],
      ),

    );
  }
}