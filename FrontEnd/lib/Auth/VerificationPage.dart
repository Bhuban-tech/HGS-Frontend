import 'package:flutter/material.dart';

class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final List<TextEditingController> otpControllers =
  List.generate(4, (_) => TextEditingController());
  String? errorMessage;

  void validateAndSubmit() {
    String otp = otpControllers.map((c) => c.text).join();

    if (otp.length == 4 && int.tryParse(otp) != null) {
      setState(() {
        errorMessage = null;
      });

      // ✅ Proceed to next step (for now show success message)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP Verified Successfully")),
      );

      // Example: Navigate to Reset Password page
      // Navigator.push(context,
      //   MaterialPageRoute(builder: (context) => ResetPasswordPage()));
    } else {
      setState(() {
        errorMessage = "Enter the 4-digit OTP code";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Verification",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                height: 200,
                child: Image.network(
                  "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSN-eRaTAHrnSKICH85AEO7J-vK8Y7ZpvLR7MOW5V_gU16jBbh2",
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "We will send you a one-time OTP to this email address.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 10),
              Text(
                widget.email, // ✅ Show email directly
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 30),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: otpControllers[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }),
              ),

              // 🔴 Show validation error
              if (errorMessage != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // 🔵 Blue Submit Button
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
