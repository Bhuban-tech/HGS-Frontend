
import 'package:HamroGharSewa/LandingPage/Landing.dart';
import 'package:flutter/material.dart';

class HeroPage extends StatelessWidget {
  const HeroPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: const Color(0xFF3A8EE6),
      ),
      backgroundColor: Colors.blue[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              Center(
                child: Image.asset('assets/logo.png', height: 120),
              ),

              const SizedBox(height: 30),

              const Text(
                'Welcome to',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF3A7BFF),
                    Color(0xFF9745F5),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: const Text(
                  'HamroGharSewa',
                  style: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Connect with verified service providers for all your home needs. From plumbing to cleaning, we've got you covered.",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.blueGrey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A8EE6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Find Services", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 15),
                      Icon(Icons.arrow_forward),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/personalinfo');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF3A8EE6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    side: const BorderSide(color: Color(0xFF3A8EE6)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Becomes a Provider", style: TextStyle(fontSize: 18)),
                      SizedBox(width: 15),
                      Icon(Icons.person_4_outlined),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              
             LandingPage(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
