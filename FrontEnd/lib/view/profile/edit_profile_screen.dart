import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/constants/api_constants.dart';
import 'package:HamroGharSewa/services/api_client.dart';
import 'package:HamroGharSewa/services/token_manager.dart';
import 'package:HamroGharSewa/view/profile/email_change_otp_screen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _newEmailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String _currentEmail = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _newEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiClient.get(ApiConstants.userProfile);
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded['data'] ?? decoded;
        setState(() {
          _nameController.text = data['userName'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
          _addressController.text = data['address'] ?? '';
          _currentEmail = data['email'] ?? '';
          _role = (data['role'] ?? '').toString().toUpperCase();
        });
      }
    } catch (e) {
      _showSnackBar('Failed to load profile', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final body = {
        'userName': _nameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };
      final response = await _apiClient.put(ApiConstants.updateProfile, body);
      if (response.statusCode == 200) {
        _showSnackBar('Profile updated successfully');
        if (mounted) Navigator.pop(context, true);
      } else {
        final decoded = jsonDecode(response.body);
        _showSnackBar(decoded['message'] ?? 'Failed to update profile', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _requestEmailChange() async {
    final newEmail = _newEmailController.text.trim();
    if (newEmail.isEmpty) {
      _showSnackBar('Please enter new email', isError: true);
      return;
    }
    setState(() => _isSaving = true);
    try {
      final response = await _apiClient.post(
        '${ApiConstants.requestEmailChange}?newEmail=$newEmail',
        null,
      );
      if (response.statusCode == 200) {
        _showSnackBar('OTP sent to $newEmail');
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmailChangeOtpScreen(newEmail: newEmail),
            ),
          );
        }
      } else {
        final decoded = jsonDecode(response.body);
        _showSnackBar(decoded['message'] ?? 'Failed to send OTP', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  Widget _field(String label, TextEditingController ctrl,
      {IconData? icon,
      bool readOnly = false,
      String? Function(String?)? validator,
      TextInputType? keyboardType}) {
    return TextFormField(
      controller: ctrl,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon ?? Icons.edit_outlined, color: AppColors.primaryBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        filled: readOnly,
        fillColor: readOnly ? Colors.grey.shade100 : null,
      ),
    );
  }

  Widget _sectionCard(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
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
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Basic info
                        _sectionCard('Basic Information', Icons.person_outline, [
                          _field('Full Name', _nameController,
                              icon: Icons.person_outline,
                              validator: (v) =>
                                  v == null || v.trim().isEmpty ? 'Name is required' : null),
                          const SizedBox(height: 16),
                          _field('Phone Number', _phoneController,
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Phone is required';
                                if (v.trim().length != 10) return 'Phone must be exactly 10 digits';
                                return null;
                              }),
                          const SizedBox(height: 16),
                          _field('Address', _addressController,
                              icon: Icons.location_on_outlined),
                          const SizedBox(height: 16),
                          // Read-only current email
                          _field('Current Email', TextEditingController(text: _currentEmail),
                              icon: Icons.email_outlined, readOnly: true),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _saveProfile,
                              icon: const Icon(Icons.save_outlined),
                              label: const Text('Save Changes'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 20),

                        // Change email
                        _sectionCard('Change Email', Icons.email_outlined, [
                          _field('New Email Address', _newEmailController,
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _isSaving ? null : _requestEmailChange,
                              icon: const Icon(Icons.send_outlined),
                              label: const Text('Send OTP'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                if (_isSaving)
                  Container(
                    color: Colors.black12,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryBlue),
                    ),
                  ),
              ],
            ),
    );
  }
}
