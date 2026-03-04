import 'package:HamroGharSewa/common/custom_text_field.dart';
import 'package:HamroGharSewa/constants/app_colors.dart';
import 'package:HamroGharSewa/services/auth_service.dart';
import 'package:HamroGharSewa/view/verifyotpscreen/verifyotpscreen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();
  String _selectedCategory = 'Plumbing';

  bool _isProvider = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim(),
        role: _isProvider ? 'PROVIDER' : 'USER',
        address: _isProvider ? _addressController.text.trim() : null,
        category: _isProvider ? _selectedCategory : null,
        experience: _isProvider ? _experienceController.text.trim() : null,
      );

      if (!mounted) return;

      if (result.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPVerificationScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Network error. Please try again."),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _isProvider
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFF6366F1), const Color(0xFF8B5CF6), const Color(0xFFD946EF)],
              ),
            ),
          ),
          
          // Background Circles
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Back Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Header
                    Column(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          child: Container(
                            key: ValueKey<bool>(_isProvider),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Icon(
                              _isProvider ? Icons.engineering_rounded : Icons.person_add_rounded,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _isProvider ? 'Join as Provider' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isProvider
                              ? 'Start growing your business'
                              : 'Join our community today',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),

                    // Register Form Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Role Toggle
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGrey.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildToggleItem('User', !_isProvider, () {
                                        if (_isProvider) {
                                          setState(() => _isProvider = false);
                                          _emailController.clear();
                                          _passwordController.clear();
                                          _phoneController.clear();
                                          _nameController.clear();
                                        }
                                      }),
                                      _buildToggleItem('Provider', _isProvider, () {
                                        if (!_isProvider) {
                                          setState(() => _isProvider = true);
                                          _emailController.clear();
                                          _passwordController.clear();
                                          _phoneController.clear();
                                          _nameController.clear();
                                        }
                                      }),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CustomTextField(
                                  controller: _nameController,
                                  hint: 'Full Name',
                                  label: 'Full Name',
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _emailController,
                                  hint: 'Email Address',
                                  label: 'Email',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (v) {
                                    if (v!.isEmpty) return 'Required';
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                                      return 'Invalid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _phoneController,
                                  hint: 'Phone Number',
                                  label: 'Phone',
                                  prefixIcon: Icons.phone_outlined,
                                  keyboardType: TextInputType.phone,
                                  validator: (v) => v!.isEmpty ? 'Required' : null,
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  label: 'Password',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                      color: AppColors.textLight,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: (v) {
                                    if (v!.isEmpty) return 'Required';
                                    if (v.length < 8) return 'Min 8 characters';
                                    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#$%^&*()_+\-{}\[\]().,<>/?]).+$')
                                        .hasMatch(v)) {
                                      return 'Must include A-Z, a-z, 0-9 & special char';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                  CustomTextField(
                                    controller: _confirmPasswordController,
                                    hint: 'Confirm Password',
                                    label: 'Confirm Password',
                                    prefixIcon: Icons.lock_clock_outlined,
                                    obscureText: _obscureConfirmPassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: AppColors.textLight,
                                      ),
                                      onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                    ),
                                    validator: (v) {
                                      if (v!.isEmpty) return 'Required';
                                      if (v != _passwordController.text) return 'Mismatch';
                                      return null;
                                    },
                                  ),
                                  
                                  // Provider-specific professional fields
                                  if (_isProvider) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.background.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedCategory,
                                        decoration: InputDecoration(
                                          labelText: 'Service Category',
                                          prefixIcon: const Icon(Icons.category_outlined, color: AppColors.primaryBlue),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        ),
                                        items: ['Plumbing', 'Electrical', 'Painting', 'Cleaning', 'Carpentry', 'Gardening']
                                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                            .toList(),
                                        onChanged: (v) => setState(() => _selectedCategory = v!),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _addressController,
                                      hint: 'Service Location / Address',
                                      label: 'Address',
                                      prefixIcon: Icons.location_on_outlined,
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextField(
                                      controller: _experienceController,
                                      hint: 'Years of Experience',
                                      label: 'Experience',
                                      prefixIcon: Icons.work_history_outlined,
                                      keyboardType: TextInputType.number,
                                      validator: (v) => v!.isEmpty ? 'Required' : null,
                                    ),
                                  ],
                                  
                                  const SizedBox(height: 32),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _handleSignUp,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryBlue,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 8,
                                    shadowColor: AppColors.primaryBlue.withOpacity(0.5),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Text(
                                          _isProvider ? 'REGISTER AS PROVIDER' : 'SIGN UP AS USER',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.textDark : AppColors.textLight,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}