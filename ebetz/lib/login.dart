import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login1.dart'; // Ensure LoginForm is imported

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _BlackThemeLoginScreenState();
}

class _BlackThemeLoginScreenState extends State<LoginScreen> {
  void _navigateToLoginForm(bool isLogin) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginForm(isLogin: isLogin),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image with transparency
          Positioned.fill(
            child: Image.asset(
              'assets/images/loginbackground.webp', // Update with correct path
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6), 
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Gradient overlay for aesthetic purpose
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(150, 7, 0, 40), 
                    Color.fromARGB(150, 38, 0, 0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/l2.png', // Logo image
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                   Text(
                    'Welcome to EBETZ',
                    style: GoogleFonts.breeSerif(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: () => _navigateToLoginForm(false),  // Navigate to Sign Up
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => _navigateToLoginForm(true),  // Navigate to Login
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Login',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
