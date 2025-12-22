import 'package:flutter/material.dart';

import 'homePage.dart'; // Make sure ProviderDashboard is defined here

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/',
    routes: {
      '/': (context) => const LandingPage(),
    },
  ));
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landing Page'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Register as Service Provider'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RegisterApp()),
            );
          },
        ),
      ),
    );
  }
}

class RegisterApp extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegisterApp> {
  int _currentStep = 0;

  final _personalFormKey = GlobalKey<FormState>();
  final _businessFormKey = GlobalKey<FormState>();
  final _verificationFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final businessController = TextEditingController();
  final hourlyRateController = TextEditingController();
  final specializationController = TextEditingController();
  final serviceAreaController = TextEditingController();

  String? kycType;
  Set<String> selectedServices = {};

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    businessController.dispose();
    hourlyRateController.dispose();
    specializationController.dispose();
    serviceAreaController.dispose();
    super.dispose();
  }

  Future<bool> _handleBack() async {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.blue,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              if (await _handleBack()) {
                Navigator.pop(context);
              }
            },
          ),
          title: const Text(
            'Plumbing: Tap Installation',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(Icons.notifications_none, color: Colors.black),
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 80,
                      width: 80,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Register as Service Provider",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      "Join our network of verified professionals",
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Stepper(
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep == 0 &&
                        _personalFormKey.currentState!.validate()) {
                      setState(() => _currentStep += 1);
                    } else if (_currentStep == 1 &&
                        _businessFormKey.currentState!.validate()) {
                      if (selectedServices.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Please select at least one service")),
                        );
                        return;
                      }
                      setState(() => _currentStep += 1);
                    } else if (_currentStep == 2 &&
                        _verificationFormKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Registration Complete")),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProviderDashboard()),
                      );
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_currentStep > 0)
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text("Back"),
                          ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child:
                              Text(_currentStep == 2 ? "Submit" : "Next"),
                        ),
                      ],
                    );
                  },
                  steps: [
                    // Step 1: Personal Info
                    Step(
                      title: const Text("1"),
                      isActive: _currentStep >= 0,
                      content: Form(
                        key: _personalFormKey,
                        child: Column(
                          children: [
                            _buildRoundedTextField(
                                "Full Name", nameController,
                                (val) =>
                                    val!.isEmpty ? "Enter your name" : null),
                            _buildRoundedTextField(
                                "Email Address", emailController,
                                (val) => val!.contains("@")
                                    ? null
                                    : "Enter valid email"),
                            _buildRoundedTextField(
                                "Phone Number", phoneController,
                                (val) => val!.length < 5
                                    ? "Enter valid phone number"
                                    : null,
                                type: TextInputType.phone),
                            _buildRoundedTextField(
                                "Address", addressController,
                                (val) => val!.isEmpty
                                    ? "Enter a valid address"
                                    : null),
                          ],
                        ),
                      ),
                    ),

                    // Step 2: Business Info
                    Step(
                      title: const Text("2"),
                      isActive: _currentStep >= 1,
                      content: Form(
                        key: _businessFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRoundedTextField(
                              "Business/Services Name *",
                              businessController,
                              (val) =>
                                  val!.isEmpty ? "Enter business name" : null,
                            ),
                            const SizedBox(height: 20),

                            const Text("Services Offered *"),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildChip("Plumbing"),
                                _buildChip("Carpentry"),
                                _buildChip("Cleaning"),
                                _buildChip("Landscaping"),
                                _buildChip("Appliance Repair"),
                                _buildChip("Electrical"),
                                _buildChip("Painting"),
                                _buildChip("HVAC"),
                                _buildChip("Home Repair"),
                                _buildChip("Interior Design"),
                              ],
                            ),
                            const SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    decoration: const InputDecoration(
                                      labelText: "Experience *",
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      "1 year",
                                      "2 years",
                                      "3 years",
                                      "5+ years",
                                      "10+ years",
                                    ].map((exp) {
                                      return DropdownMenuItem(
                                          value: exp, child: Text(exp));
                                    }).toList(),
                                    onChanged: (val) {},
                                    validator: (val) =>
                                        val == null ? "Select experience" : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextFormField(
                                    controller: hourlyRateController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: "Hourly Rate (NPR) *",
                                      prefixText: "₨ ",
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (val) =>
                                        val!.isEmpty ? "Enter rate" : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            _buildRoundedTextField(
                              "Specialization",
                              specializationController,
                              (val) => null,
                            ),
                            const SizedBox(height: 20),

                            _buildRoundedTextField(
                              "Service Area",
                              serviceAreaController,
                              (val) => null,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Step 3: Verification
                    Step(
                      title: const Text("3"),
                      isActive: _currentStep >= 2,
                      content: Form(
                        key: _verificationFormKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: "KYC Document Type *",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              value: kycType,
                              items: ["Passport", "ID Card", "Driving License"]
                                  .map((e) =>
                                      DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                              onChanged: (val) => setState(() => kycType = val),
                              validator: (val) =>
                                  val == null ? "Select document type" : null,
                            ),
                            const SizedBox(height: 20),

                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey, style: BorderStyle.solid),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.upload_file,
                                      size: 40, color: Colors.grey),
                                  const SizedBox(height: 10),
                                  const Text(
                                    "Click to upload your KYC document",
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  const Text(
                                    "PDF, JPG, PNG (Max 10MB)",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      // File upload logic here
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text("Upload KYC Document"),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            const Text(
                              "Portfolio Images (Optional)",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // File picker logic here
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Choose Files"),
                                ),
                                const SizedBox(width: 10),
                                const Text("No file chosen"),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundedTextField(String label,
      TextEditingController controller, String? Function(String?) validator,
      {TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildChip(String label) {
    return StatefulBuilder(
      builder: (context, setStateSB) {
        final isSelected = selectedServices.contains(label);
        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            setStateSB(() {
              if (selected) {
                selectedServices.add(label);
              } else {
                selectedServices.remove(label);
              }
            });
          },
        );
      },
    );
  }
}
