import 'package:ebetz/login1.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'admin_page.dart';
import 'navigation.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _helmetFallAnimation;
  late Animation<double> _helmetBounceAnimation;
  late Animation<double> _textFollowAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set up the animation controller
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Helmet fall and bounce animation
    _helmetFallAnimation = Tween<double>(begin: -200, end: 150).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _helmetBounceAnimation = Tween<double>(begin: 150, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.bounceOut)),
    );

    // Text follow animation to move with the helmet during bounce
    _textFollowAnimation = Tween<double>(begin: 300, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.7, 1.0, curve: Curves.bounceOut)),
    );

    // Scale animation to emphasize the entrance of both helmet and text
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Fade animation to smooth the start and end
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.8, curve: Curves.easeInOut)),
    );

    // Start the animation
    _controller.forward();

    // Check login status and navigate after animation ends
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    bool? isAdmin = prefs.getBool('isAdmin');

    // Delay to sync with the animation
    await Future.delayed(const Duration(seconds: 5));

    // Navigate based on the login state
    if (isLoggedIn == true) {
      if (isAdmin == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavigatorScreen(0)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated helmet with falling and bouncing effect
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double position = _controller.value <= 0.5
                    ? _helmetFallAnimation.value
                    : _helmetBounceAnimation.value;
                return Transform.translate(
                  offset: Offset(0, position),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Image.asset(
                'assets/images/Helmet2.png', // Your helmet image
                height: 120,
              ),
            ),
            const SizedBox(height: 20),

            // "EBETZ" text following the helmet bounce to the center with scaling effect
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                double position = _controller.value <= 0.5
                    ? _textFollowAnimation.value + 150
                    : _textFollowAnimation.value;
                return Transform.translate(
                  offset: Offset(0, position),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  ),
                );
              },
              child: Text(
                'EBETZ',
                style: GoogleFonts.breeSerif(
                  fontSize: 55,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}