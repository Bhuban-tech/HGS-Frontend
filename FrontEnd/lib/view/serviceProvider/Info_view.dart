// import 'package:HamroGharSewa/constants/app_colors.dart';
// import 'package:HamroGharSewa/providers/service_provider.dart';
// import 'package:HamroGharSewa/DashBoard/provider_dashboard_view.dart';
// import 'package:HamroGharSewa/DashBoard/User.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class BecomeProviderPage extends StatefulWidget {
//   const BecomeProviderPage({Key? key}) : super(key: key);

//   @override
//   State<BecomeProviderPage> createState() => _BecomeProviderPageState();
// }

// class _BecomeProviderPageState extends State<BecomeProviderPage> {
//   int _currentStep = 0;
//   final int _totalSteps = 3;
//   final PageController _pageController = PageController();

//   // Form Keys
//   final _personalFormKey = GlobalKey<FormState>();
//   final _professionalFormKey = GlobalKey<FormState>();
//   final _verificationFormKey = GlobalKey<FormState>();

//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _experienceController = TextEditingController();
//   final TextEditingController _skillsController = TextEditingController();
//   final TextEditingController _citizenshipController = TextEditingController();

//   String _selectedCategory = 'Plumbing';
//   final List<String> _categories = [
//     'Plumbing',
//     'Electrical',
//     'Painting',
//     'Cleaning',
//     'Carpentry',
//     'Gardening',
//   ];

//   @override
//   void dispose() {
//     _pageController.dispose();
//     _nameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _experienceController.dispose();
//     _skillsController.dispose();
//     _citizenshipController.dispose();
//     super.dispose();
//   }

//   void _nextStep() {
//     if (_currentStep == 0) {
//       if (!_personalFormKey.currentState!.validate()) return;
//     } else if (_currentStep == 1) {
//       if (!_professionalFormKey.currentState!.validate()) return;
//     } else if (_currentStep == 2) {
//       if (!_verificationFormKey.currentState!.validate()) return;
//       _submitApplication();
//       return;
//     }

//     if (_currentStep < _totalSteps - 1) {
//       setState(() => _currentStep++);
//       _pageController.animateToPage(
//         _currentStep,
//         duration: const Duration(milliseconds: 600),
//         curve: Curves.easeInOutCubicEmphasized,
//       );
//     }
//   }

//   void _prevStep() {
//     if (_currentStep > 0) {
//       setState(() => _currentStep--);
//       _pageController.animateToPage(
//         _currentStep,
//         duration: const Duration(milliseconds: 600),
//         curve: Curves.easeInOutCubicEmphasized,
//       );
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   Future<void> _submitApplication() async {
//     final provider = Provider.of<ServiceProvider>(context, listen: false);

//     final data = {
//       'name': _nameController.text.trim(),
//       'phone': _phoneController.text.trim(),
//       'address': _addressController.text.trim(),
//       'category': _selectedCategory,
//       'experience': _experienceController.text.trim(),
//       'skills': _skillsController.text.trim(),
//       'citizenship': _citizenshipController.text.trim(),
//     };

//     final success = await provider.submitProviderApplication(data);

//     if (success && mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const ProviderApplicationSuccessPage(),
//         ),
//       );
//     } else if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Failed to submit application. Please try again.'),
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildHeader(),
//             Expanded(
//               child: PageView(
//                 controller: _pageController,
//                 physics: const NeverScrollableScrollPhysics(),
//                 children: [
//                   _buildStep1Personal(),
//                   _buildStep2Professional(),
//                   _buildStep3Verification(),
//                 ],
//               ),
//             ),
//             _buildBottomBar(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.arrow_back_ios, size: 20),
//                 onPressed: _prevStep,
//                 padding: EdgeInsets.zero,
//                 constraints: const BoxConstraints(),
//               ),
//               const SizedBox(width: 16),
//               const Text(
//                 'Become a Provider',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: AppColors.textDark,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Stack(
//             children: [
//               Container(
//                 height: 6,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: AppColors.lightGrey,
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 600),
//                 curve: Curves.easeInOut,
//                 height: 6,
//                 width:
//                 MediaQuery.of(context).size.width *
//                     ((_currentStep + 1) / _totalSteps),
//                 decoration: BoxDecoration(
//                   gradient: const LinearGradient(
//                     colors: [AppColors.gradientStart, AppColors.gradientEnd],
//                   ),
//                   borderRadius: BorderRadius.circular(3),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Step ${_currentStep + 1} of $_totalSteps',
//             style: const TextStyle(
//               color: AppColors.textLight,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStep1Personal() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Form(
//         key: _personalFormKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             _buildSectionTitle('Basic Information', 'Tell us about yourself'),
//             const SizedBox(height: 32),
//             _buildTextField(
//               controller: _nameController,
//               label: 'Full Name',
//               icon: Icons.person_outline,
//               validator: (v) => v!.isEmpty ? 'Name is required' : null,
//             ),
//             const SizedBox(height: 20),
//             _buildTextField(
//               controller: _phoneController,
//               label: 'Phone Number',
//               icon: Icons.phone_outlined,
//               keyboardType: TextInputType.phone,
//               validator: (v) => v!.isEmpty ? 'Phone is required' : null,
//             ),
//             const SizedBox(height: 20),
//             _buildTextField(
//               controller: _addressController,
//               label: 'Address',
//               icon: Icons.location_on_outlined,
//               validator: (v) => v!.isEmpty ? 'Address is required' : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStep2Professional() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Form(
//         key: _professionalFormKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             _buildSectionTitle(
//               'Professional Info',
//               'What services do you provide?',
//             ),
//             const SizedBox(height: 32),
//             _buildDropdown(
//               label: 'Service Category',
//               value: _selectedCategory,
//               items: _categories,
//               onChanged: (val) => setState(() => _selectedCategory = val!),
//             ),
//             const SizedBox(height: 20),
//             _buildTextField(
//               controller: _experienceController,
//               label: 'Years of Experience',
//               icon: Icons.work_history_outlined,
//               keyboardType: TextInputType.number,
//               validator: (v) => v!.isEmpty ? 'Experience is required' : null,
//             ),
//             const SizedBox(height: 20),
//             _buildTextField(
//               controller: _skillsController,
//               label: 'Skills / Description',
//               icon: Icons.lightbulb_outline,
//               maxLines: 3,
//               validator: (v) => v!.isEmpty ? 'Description is required' : null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStep3Verification() {
//     return SingleChildScrollView(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Form(
//         key: _verificationFormKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             _buildSectionTitle('Identity & Validation', 'Verify your identity'),
//             const SizedBox(height: 32),
//             _buildTextField(
//               controller: _citizenshipController,
//               label: 'Citizenship Number',
//               icon: Icons.badge_outlined,
//               validator: (v) => v!.isEmpty ? 'ID Number is required' : null,
//             ),
//             const SizedBox(height: 24),
//             _buildUploadCard('Citizenship (Front)'),
//             const SizedBox(height: 16),
//             _buildUploadCard('Citizenship (Back)'),
//             const SizedBox(height: 16),
//             _buildUploadCard('Profile Photo'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(String title, String subtitle) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: AppColors.textDark,
//             letterSpacing: -0.5,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           subtitle,
//           style: const TextStyle(fontSize: 16, color: AppColors.textLight),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     int maxLines = 1,
//     String? Function(String?)? validator,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: keyboardType,
//         maxLines: maxLines,
//         validator: validator,
//         style: const TextStyle(
//           fontWeight: FontWeight.w600,
//           color: AppColors.textDark,
//         ),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: AppColors.textLight),
//           prefixIcon: Icon(icon, color: AppColors.primaryBlue),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.transparent,
//           contentPadding: const EdgeInsets.all(20),
//         ),
//       ),
//     );
//   }

//   Widget _buildDropdown({
//     required String label,
//     required String value,
//     required List<String> items,
//     required Function(String?) onChanged,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.03),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: DropdownButtonFormField<String>(
//         value: value,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: const TextStyle(color: AppColors.textLight),
//           prefixIcon: const Icon(
//             Icons.category_outlined,
//             color: AppColors.primaryBlue,
//           ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(20),
//             borderSide: BorderSide.none,
//           ),
//           filled: true,
//           fillColor: Colors.transparent,
//           contentPadding: const EdgeInsets.all(20),
//         ),
//         items:
//         items
//             .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//             .toList(),
//       ),
//     );
//   }

//   Widget _buildUploadCard(String title) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: AppColors.lightGrey, width: 1.5),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: 0.02),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Icon(
//             Icons.cloud_upload_outlined,
//             size: 32,
//             color: AppColors.primaryBlue.withValues(alpha: 0.6),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: AppColors.textDark,
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(height: 4),
//           const Text(
//             'Tap to upload',
//             style: TextStyle(color: AppColors.textLight, fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomBar() {
//     return SafeArea(
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         child: Consumer<ServiceProvider>(
//           builder: (context, provider, child) {
//             return ElevatedButton(
//               onPressed: provider.isLoading ? null : _nextStep,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.primaryBlue,
//                 foregroundColor: Colors.white,
//                 minimumSize: const Size(double.infinity, 60),
//                 padding: const EdgeInsets.symmetric(vertical: 20),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 elevation: 8,
//                 shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
//               ),
//               child:
//               provider.isLoading
//                   ? const SizedBox(
//                 height: 24,
//                 width: 24,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//                   : Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     _currentStep == _totalSteps - 1
//                         ? 'Submit & Review'
//                         : 'Next Step',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   if (_currentStep < _totalSteps - 1)
//                     const Padding(
//                       padding: EdgeInsets.only(left: 8.0),
//                       child: Icon(
//                         Icons.arrow_forward_rounded,
//                         size: 20,
//                       ),
//                     ),
//                 ],
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────────────────────────────────────
// // Success Page
// // ─────────────────────────────────────────────────────────────────────────────

// class ProviderApplicationSuccessPage extends StatelessWidget {
//   const ProviderApplicationSuccessPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: BoxDecoration(
//                 color: AppColors.success.withValues(alpha: 0.1),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(
//                 Icons.check_rounded,
//                 color: AppColors.success,
//                 size: 64,
//               ),
//             ),
//             const SizedBox(height: 32),
//             const Text(
//               'Application Received!',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textDark,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Your application is under review. Our team will verify your details and activate your profile soon.',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: AppColors.textMedium,
//                 height: 1.5,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 48),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () {
//                    Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const ProviderDashboard()),
//                     (route) => false,
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryBlue,
//                   padding: const EdgeInsets.symmetric(vertical: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   elevation: 5,
//                 ),
//                 child: const Text(
//                   'Enter Provider Dashboard',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             const Text(
//               'Tip: If you don\'t see the new dashboard, please Log out and Log in again to refresh your account.',
//               style: TextStyle(fontSize: 12, color: AppColors.textLight, fontStyle: FontStyle.italic),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: OutlinedButton(
//                 onPressed: () {
//                    Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const UserDashboard()),
//                         (route) => false,
//                   );
//                 },
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 20),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   side: const BorderSide(color: AppColors.primaryBlue),
//                 ),
//                 child: const Text(
//                   'Check Application Status',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: AppColors.primaryBlue,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }