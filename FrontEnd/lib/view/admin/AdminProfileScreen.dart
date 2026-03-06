import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/api_client.dart';
import 'package:HamroGharSewa/services/token_manager.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  final TokenManager _tokenManager = TokenManager();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoading = false;
  bool _otpSent = false;
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _newEmailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _profile = decoded['data'];
          _nameController.text = _profile?['userName'] ?? '';
          _phoneController.text = _profile?['phoneNumber'] ?? '';
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load profile', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.put(
      ApiConstants.updateProfile,
        {
          'userName': _nameController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
        },
      );
      if (response.statusCode == 200) {
        _showSnackBar('Profile updated successfully!');
        _loadProfile();
      } else {
        _showSnackBar('Failed to update profile', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestEmailChange() async {
    final newEmail = _newEmailController.text.trim();
    if (newEmail.isEmpty) {
      _showSnackBar('Please enter new email', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(
        '${ApiConstants.requestEmailChange}?newEmail=$newEmail',
        null,
      );
      if (response.statusCode == 200) {
        setState(() => _otpSent = true);
        _showSnackBar('OTP sent to $newEmail');
      } else {
        final decoded = jsonDecode(response.body);
        _showSnackBar(decoded['message'] ?? 'Failed to send OTP', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmEmailChange() async {
    final newEmail = _newEmailController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      _showSnackBar('Please enter OTP', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.post(
        '${ApiConstants.confirmEmailChange}?newEmail=$newEmail&otp=$otp',
        null,
      );
      if (response.statusCode == 200) {
        _showSnackBar('Email changed successfully!');
        await _tokenManager.logout(context);
        setState(() {
          _otpSent = false;
          _newEmailController.clear();
          _otpController.clear();
        });
        _loadProfile();
      } else {
        final decoded = jsonDecode(response.body);
        _showSnackBar(decoded['message'] ?? 'Invalid OTP', isError: true);
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
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
                child: Icon(icon, color: AppColors.primaryBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {IconData? icon, bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon ?? Icons.edit, color: AppColors.primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading && _profile == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      (_profile?['userName'] ?? 'A')[0].toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _profile?['email'] ?? '',
                  style:
                  TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Basic Info Section
                _buildSection(
                  'Basic Information',
                  Icons.person,
                  [
                    _buildTextField('Full Name', _nameController,
                        icon: Icons.person),
                    const SizedBox(height: 16),
                    _buildTextField('Phone Number', _phoneController,
                        icon: Icons.phone),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.email, color: AppColors.primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          _profile?['email'] ?? '',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _updateProfile,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Changes'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Change Email Section
                _buildSection(
                  'Change Email',
                  Icons.email,
                  [
                    _buildTextField(
                        'New Email Address', _newEmailController,
                        icon: Icons.email),
                    const SizedBox(height: 12),

                    if (!_otpSent)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed:
                          _isLoading ? null : _requestEmailChange,
                          icon: const Icon(Icons.send),
                          label: const Text('Send OTP'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),

                    if (_otpSent) ...[
                      const SizedBox(height: 12),
                      _buildTextField('Enter OTP', _otpController,
                          icon: Icons.lock),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () =>
                                  setState(() => _otpSent = false),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12)),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _confirmEmailChange,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12)),
                              ),
                              child: const Text('Verify OTP'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black12,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryBlue),
                ),
              ),
            ),
        ],
      ),
    );
  }
}