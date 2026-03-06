import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';

/// Search bar widget for user dashboard
/// Positioned to overlap the gradient header
class UserSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const UserSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: -28,
      left: 20,
      right: 20,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              hintText: 'Search for services...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              icon: Icon(Icons.search_rounded, color: AppColors.textLight),
              suffixIcon: Icon(
                Icons.tune_rounded,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
