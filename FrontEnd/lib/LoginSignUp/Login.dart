
import 'package:HamroGharSewa/LoginSignUp/ServiceProviderSignUp.dart';
import 'package:HamroGharSewa/LoginSignUp/UserSignUp.dart';
import 'package:flutter/material.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeService Platform',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isUserSelected = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Image.asset(
                "assets/logoo.png",
                height: 150,
              ),
              const Text(
                "Login to HamroGharSewa",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Toggle Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isUserSelected = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isUserSelected ? Colors.green : Colors.white,
                        foregroundColor:
                            isUserSelected ? Colors.white : Colors.black,
                        side: const BorderSide(color: Colors.green),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Text("Customer"),
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isUserSelected = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !isUserSelected ? Colors.green : Colors.white,
                        foregroundColor:
                            !isUserSelected ? Colors.white : Colors.black,
                        side: const BorderSide(color: Colors.green),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                      ),
                      child: const Text("Service Provider"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // Email Input
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  hintText: "username@gmail.com",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: TextButton(
                    onPressed: () {
                      // forgot password action
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Sign Up Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      if (isUserSelected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UserSignUp()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const ServiceProviderSignUp()),
                        );
                      }
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Login Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // login action
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Google Button
              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // google login
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.network(
                    "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png",
                    height: 24,
                    width: 24,
                  ),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(fontSize: 16, color: Colors.black),
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
