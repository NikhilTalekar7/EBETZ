import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'community.dart';
import 'feedback.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login1.dart';
import 'sqflite_helper_database.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
   final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
 
  int matchesPlayed = 0;
  int matchesWon = 0;
  

  final ImagePicker _picker = ImagePicker();
  File? profileImage;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _loadUserProfile().then((_) {
      _controller.forward(); 
       fetchUserProfile();
    });
    _controller.forward();
   
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  int followers = 0;
  int following = 0;
   Future<void> fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            matchesPlayed = userDoc['matchPlayed'] ?? 0;
            matchesWon = userDoc['matchesWin'] ?? 0;
              followers = userDoc['followers'] ?? 0;
              following = userDoc['following'] ?? 0;
          });
        } else {
          log("User document does not exist.");
        }
      } catch (e) {
        log("Error fetching user profile: $e");
      }
    } else {
      log("No user is currently signed in.");
    }
  }
  Future<void> _loadUserProfile() async {
    try {
      // Fetch user profile image path from local database
      String? imagePath = await DatabaseHelper().fetchProfileImage();
      if (imagePath != null && imagePath.isNotEmpty) {
        setState(() {
          profileImage = File(imagePath); // Load the image file using the path
        });
      }
    } catch (e) {
      print("Error loading user profile: $e");
    }
  }

  // Pick an image from gallery and update the profile image
  Future<void> pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          profileImage =
              File(pickedFile.path); // Update the profileImage variable
        });

        // Save the image path to the database
        await DatabaseHelper().insertProfileImage(pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }
  
  Future<String?> getUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc['username'] as String?;
    }
    return null;
  }
 

  Future<void> copyReferralLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Referral link copied!")),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 600; // Small screen check (e.g., for phones)

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 0, 41, 1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: GoogleFonts.breeSerif(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                  Color.fromRGBO(0, 0, 41, 1),
                 Color.fromRGBO(53, 52, 92, 1),
              
                  
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(0, 0, 41, 1),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      backgroundImage: profileImage != null
                          ? FileImage(profileImage!)
                          : null,
                      child: profileImage == null
                          ? const Icon(Icons.person, size: 40, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<String?>(
                      future: getUsername(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "Loading...",
                            style: GoogleFonts.breeSerif(
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text(
                            "No Username",
                            style: GoogleFonts.breeSerif(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }
                        return Text(
                          snapshot.data!,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              _buildOthersCard(Icons.people, "Terms & Conditions", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CommunityScreen(),
                  ),
                );
              }),
              _buildOthersCard(Icons.feedback, "Feedback", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackScreen(),
                  ),
                );
              }),
              
              _buildOthersCard(Icons.logout, "Logout", () async {
                final prefs = await SharedPreferences.getInstance();

                // Clear all SharedPreferences data
                await prefs.clear();

                // Navigate to the LoginForm screen
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginForm(isLogin: false),
                  ),
                  (route) => false, // Removes all previous routes
                );
              }),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.white,
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              height: screenHeight,
             
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 0, 41, 1),
                     Color.fromRGBO(53, 52, 92, 1),
                   
                      
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
                padding: EdgeInsets.all(
                  isSmallScreen ? 16 : 24), // Padding based on screen size
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: pickImage,
                    child: CircleAvatar(
                      radius: isSmallScreen
                          ? 50
                          : 60, // Adjust size based on screen size
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      backgroundImage:
                          profileImage != null ? FileImage(profileImage!) : null,
                      child: profileImage == null
                          ? const Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  FutureBuilder<String?>(
                    future: getUsername(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          "Loading...",
                          style: GoogleFonts.breeSerif(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        );
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return Text(
                          "No Username",
                          style: GoogleFonts.breeSerif(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }
                      return Text(
                        snapshot.data!,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                   const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _statText("Followers", followers),
                              const SizedBox(width: 40),
                            _statText("Following", following),
          
                          ],
                        ),
                  const SizedBox(height: 30),
                  _buildStatsSection(isSmallScreen),
                  const SizedBox(height: 30),
                  _buildReferAndEarnCard(),
                  const SizedBox(height: 20),
                  Text(
                    "Invite your friends to join and earn amazing rewards when they sign up using your referral link.",
                    style: GoogleFonts.cairo(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
  await fetchUserProfile(); 
  setState(() {
    
  }); // Restart the fade animation
}

  Widget _buildOthersCard(IconData icon, String text, Function() onTap) {
    return Card(
      color: Color.fromARGB(255, 0, 77, 158),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: GoogleFonts.breeSerif(color: Colors.white, fontSize: 18),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatsSection(bool isSmallScreen) {
    return Row(
      mainAxisAlignment: isSmallScreen
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceAround,
      children: [
        _buildStatsCard(
            "Matches Played", matchesPlayed.toString(), isSmallScreen),
        _buildStatsCard("Matches Won", matchesWon.toString(), isSmallScreen),
        // _buildStatsCard("Matches Lost", matchesLost.toString(), isSmallScreen),
      ],
    );
  }

  Widget _buildStatsCard(String title, String value, bool isSmallScreen) {
    return Expanded(
      child: Card(
        color:Color.fromARGB(255, 0, 77, 158),
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(color: Colors.white,fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.breeSerif(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 18 : 22,
                ),
                overflow: TextOverflow.ellipsis, // Prevent overflow
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReferAndEarnCard() {
    return Card(
      color: Color.fromARGB(255, 0, 77, 158),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.share, color: Colors.white),
        title: Text(
          "Refer and Earn",
          style: GoogleFonts.cairo(color: Colors.white, fontSize: 18,fontWeight: FontWeight.w900),
        ),
        onTap: () {
          copyReferralLink("https://www.example.com/referral");
        },
      ),
    );
  }
}
 // Reusable Widget for Followers and Following Text
  Widget _statText(String title, int value) {
    return Column(
      children: [
        Text(
          "$value",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

