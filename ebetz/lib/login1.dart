import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebetz/navigation.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'Firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import 'admin_page.dart';

class LoginForm extends StatefulWidget {
  final bool isLogin;

  const LoginForm({super.key, required this.isLogin});

  @override
  State createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  bool _isPressed = false;
  bool _isLoading = false;

  late bool _isLogin;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;

    // Check login status on app startup
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    bool? isAdmin = prefs.getBool('isAdmin');

    if (isLoggedIn == true) {
      // Navigate based on user role
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
    }
  }

  Future<void> _saveLoginState(bool isAdmin) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isAdmin', isAdmin);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    super.dispose();
  }

  void showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: backgroundColor,
      ),
    );
  }
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  //  Future<void> _signInWithGoogle() async {
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn();
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  //     if (googleUser != null) {
  //       final GoogleSignInAuthentication googleAuth =
  //           await googleUser.authentication;

  //       final OAuthCredential credential = GoogleAuthProvider.credential(
  //         accessToken: googleAuth.accessToken,
  //         idToken: googleAuth.idToken,
  //       );

  //       await _auth.signInWithCredential(credential);
  //       print("Google login successful!");
  //     }
  //   } catch (e) {
  //     print("Error with Google login: $e");
  //   }
  // }

  // Future<void> _signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login();

  //     if (result.status == LoginStatus.success) {
  //       final OAuthCredential credential =
  //           FacebookAuthProvider.credential(result.accessToken!.token);

  //       await _auth.signInWithCredential(credential);
  //       print("Facebook login successful!");
  //     } else {
  //       print("Facebook login failed: ${result.message}");
  //     }
  //   } catch (e) {
  //     print("Error with Facebook login: $e");
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/d.jpg',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          _isLoading
              ? const Center(
                  child: SpinKitFadingCube(
                    color: Colors.orange,
                    size: 50.0,
                  ),
                )
              : Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/l2.png',
                            height: screenHeight * 0.18,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            _isLogin ? 'Login' : 'Sign Up',
                            style: GoogleFonts.poppins(
                              fontSize: screenHeight * 0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          if (!_isLogin)
                            TextField(
                              controller: userNameController,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person_2_outlined,
                                    color: Colors.white),
                                labelText: 'User Name',
                                labelStyle:
                                    GoogleFonts.lato(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.grey[850],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          SizedBox(height: screenHeight * 0.02),
                          TextField(
                            controller: emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.email_outlined,
                                  color: Colors.white),
                              labelText: 'Email ID',
                              labelStyle:
                                  GoogleFonts.lato(color: Colors.white54),
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          TextField(
                            controller: passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline,
                                  color: Colors.white),
                              labelText: 'Password',
                              labelStyle:
                                  GoogleFonts.lato(color: Colors.white54),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.white54,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.015),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password?',
                                style: GoogleFonts.poppins(
                                  color: Colors.blue,
                                  fontSize: screenHeight * 0.02,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          GestureDetector(
                            onTapDown: (_) => setState(() => _isPressed = true),
                            onTapUp: (_) => setState(() => _isPressed = false),
                            onTap: () async {
                              String email = emailController.text.trim();
                              String password = passwordController.text.trim();
                              String userName = userNameController.text.trim();

                              setState(() {
                                _isLoading = true;
                              });

                              if (_isLogin) {
                                // Login logic
                                User? user = await _authService
                                    .loginWithEmailAndPassword(email, password);
                                if (user != null) {
                                  DocumentSnapshot userDoc =
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(user.uid)
                                          .get();

                                  setState(() {
                                    _isLoading = false;
                                  });

                                  if (userDoc.exists &&
                                      userDoc['isAdmin'] == true) {
                                    await _saveLoginState(true);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const AdminPage()),
                                    );
                                  } else {
                                    await _saveLoginState(false);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const NavigatorScreen(0)),
                                    );
                                  }
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  showSnackBar(
                                      'Login failed: Incorrect email or password.',
                                      Colors.red);
                                }
                              } else {
                                // Sign up logic
                                User? user = await _authService
                                    .registerWithEmailAndPassword(
                                        email, password, userName);
                                if (user != null) {
                                  await _saveLoginState(false);
                                  setState(() {
                                    _isLoading = false;
                                  });

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const NavigatorScreen(0)),
                                  );
                                } else {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  showSnackBar(
                                      'Sign Up failed. Please try again.',
                                      Colors.red);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              width: screenWidth * 0.8,
                              decoration: BoxDecoration(
                                color: _isPressed
                                    ? Colors.orange.shade700
                                    : Colors.orange,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _isLogin ? 'Login' : 'Sign Up',
                                  style: GoogleFonts.lato(
                                      fontSize: screenHeight * 0.02,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.04),
                          // Social Media Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(FontAwesomeIcons.google,
                                    color: Colors.red),
                                onPressed: () {
                                  // Opens Google in a browser
                                },
                              ),
                              IconButton(
                                icon: const Icon(FontAwesomeIcons.facebook,
                                    color: Colors.blue),
                                onPressed: () {
                                  // Opens Facebook in a browser
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: RichText(
                              text: TextSpan(
                                text: _isLogin
                                    ? "Don't have an account? "
                                    : "Already have an account? ",
                                style: GoogleFonts.lato(color: Colors.white54),
                                children: [
                                  TextSpan(
                                    text: _isLogin ? 'Sign Up' : 'Login',
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
