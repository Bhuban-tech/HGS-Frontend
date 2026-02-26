import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/api_client.dart';
import 'dart:convert';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final _categoryController = TextEditingController();
  final _categoryDescriptionController = TextEditingController();
  final _apiClient = ApiClient();

  bool _isLoading = false;

  @override
  void dispose() {
    _categoryController.dispose();
    _categoryDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) {
      _showSnackBar('Please enter a category name', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _apiClient.post(
        ApiConstants.adminCategories,
        {
          'name': name,
          'description': _categoryDescriptionController.text.trim(),
          'icon': 'category',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSnackBar('Category created successfully!');
        _categoryController.clear();
        _categoryDescriptionController.clear();

        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        final decoded = jsonDecode(response.body);
        final errorMsg = decoded['message'] ?? 'Failed to create category';
        _showSnackBar(errorMsg, isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Service Category', style: TextStyle(
          color: Colors.white
        ),),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.category,
                            color: AppColors.primaryBlue, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Create Service Category",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: "Category Name",
                      hintText: "e.g. Home Cleaning, Plumbing",
                      prefixIcon:
                      Icon(Icons.edit, color: AppColors.primaryBlue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _categoryDescriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Description (Optional)",
                      hintText: "Brief description...",
                      prefixIcon: Icon(Icons.description,
                          color: AppColors.primaryBlue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createCategory,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text(
                        "Create Category",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}