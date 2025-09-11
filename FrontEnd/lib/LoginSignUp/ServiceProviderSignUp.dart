import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ServiceProviderSignUp extends StatefulWidget {
  const ServiceProviderSignUp({super.key});

  @override
  State<ServiceProviderSignUp> createState() => _ServiceProviderSignUpState();
}

class _ServiceProviderSignUpState extends State<ServiceProviderSignUp> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController pricingController = TextEditingController();

  // For file upload
  String? uploadedFileName;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        uploadedFileName = result.files.single.name;
      });
    } else {
      setState(() {
        uploadedFileName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Sign Up as Service Provider",
          style: TextStyle(
            color: Colors.white,
          ),
          ),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Create Service Provider Account",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join HomeServe Connect as a service provider and expand your reach. Fill in your details below.",
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 20),

                // Full Name
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your full name" : null,
                ),
                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your email" : null,
                ),
                const SizedBox(height: 15),

                // Password
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your password" : null,
                ),
                const SizedBox(height: 15),

                // Phone Number
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone Number",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your phone number" : null,
                ),
                const SizedBox(height: 15),

                // Address
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: "Address (City, District)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your address" : null,
                ),
                const SizedBox(height: 15),

                // Experience Details
                TextFormField(
                  controller: experienceController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Your Experience Details",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty
                      ? "Please describe your professional experience"
                      : null,
                ),
                const SizedBox(height: 15),

                // Primary Service Category
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: "Primary Service Category (e.g. Plumbing, Electrical)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter your service category" : null,
                ),
                const SizedBox(height: 15),

                // Pricing
                TextFormField(
                  controller: pricingController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Service Pricing Details (e.g. per hour)",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Please enter pricing details" : null,
                ),
                const SizedBox(height: 20),

                // File Upload
                GestureDetector(
                  onTap: pickFile,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: uploadedFileName == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, size: 30),
                                Text("Click to upload PNG, JPG, or PDF",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black54)),
                              ],
                            )
                          : Text(
                              "Uploaded: $uploadedFileName ✅",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() &&
                          uploadedFileName != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Sign Up Successful ✅")),
                        );
                        // TODO: send data to backend
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Please fill all the fields and upload file")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
