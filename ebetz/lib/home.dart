import 'dart:async';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:ebetz/game_wise_tournaments.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'topplayer.dart';
import 'wallet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _EsportsBettingScreenState();
}

class _EsportsBettingScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // Top event map
  final List<Map> topEventDescriptions = [
    {
      "img": 'assets/home_images/pmgc1.webp',
      "url": 'https://www.youtube.com/live/RmdSEsbCqA0?si=Z0SPDfIaC-5YjOM0',
    },
    {
      "img": 'assets/home_images/bgms1.webp',
      "url": 'https://www.youtube.com/live/uhm5LMoXVCM?si=yFFLPRIu2ox36WP6',
    },
    {
      "img": 'assets/home_images/freefire1.webp',
      "url": 'https://www.youtube.com/live/h2F3T3HNRbA?si=kfo45P-HoaLjuYhn',
    },
    {
      "img": 'assets/home_images/codm1.jpg',
      "url": 'https://www.youtube.com/live/vU63yuKSTcg?si=Vmp57ulZ7DeRAQ83',
    },
     {
      "img": 'assets/home_images/indus1.webp',
      "url": 'https://youtu.be/gJe6RwlPGVY?si=Pt7LfnKbl8YIOnuL',
    },
     {
      "img": 'assets/home_images/Map.jpg',
      "url": 'https://www.youtube.com/live/4TrqCMgdFy4?si=83-kR91q3qZhOm_3',
    },
    
    {
      "img": 'assets/home_images/sky.jpg',
      "url": 'https://www.youtube.com/live/5Se9241KziE?si=_h4Jk_yDHhwYYSss',
    },
  ];


Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}

  //topplayer map
  final List<Map<String, dynamic>> topplayers = [
    {
      "image": 'assets/home_images/bgmi.jpg',
      "userName": 'Aditya007',
    },
    {
      "image": 'assets/home_images/freefire.jpg',
      "userName": 'Nikhil4141',
    },
    {
      "image": 'assets/home_images/codm.jpg',
      "userName": 'Dilip1414',
    },
    {
      "image": 'assets/home_images/apexlegend.png',
      "userName": 'Akashhh',
    },
  ];

  late ScrollController _scrollController;
  Timer? _scrollTimer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;

      if (currentScroll >= maxScroll) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.animateTo(
          currentScroll + 50,
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
        );
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to get the username from Firestore
  Future<String?> getUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      return userDoc['username'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const colors = [
      Color.fromRGBO(0, 0, 41, 1),
      Color.fromRGBO(53, 52, 92, 1),
    ];
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                //vertical: screenHeight * 0.05,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: screenHeight * 0.07,
                  ),
                  // Welcome Text and Wallet Button
                  Text(
                    "Hello,",
                    style: GoogleFonts.breeSerif(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  Row(
                    children: [
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
                      const Spacer(),
                      IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FutureBuilder<String?>(
                                  future:
                                      getUsername(), // Future that retrieves the username
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      // Show a loading indicator while waiting for the Future to complete
                                      return const Scaffold(
                                        body: Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    } else if (snapshot.hasError) {
                                      // Show an error message if the Future throws an error
                                      return Scaffold(
                                        body: Center(
                                            child: Text(
                                                'Error: ${snapshot.error}')),
                                      );
                                    } else if (snapshot.hasData &&
                                        snapshot.data != null) {
                                      // Pass the username to MyWallet when data is available and non-null
                                      return MyWallet(username: snapshot.data!);
                                    } else {
                                      // Handle the case where the username is null or no data is returned
                                      return const Scaffold(
                                        body: Center(
                                            child: Text('No username found.')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                          icon: Image.asset(
                            "assets/cutout/wallet4.gif",
                            height: 50,
                            width: 50,
                          )),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.03),

                  // Main content with vertical scroll
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Events Section
                          Text(
                            "Top Events",
                            style: GoogleFonts.breeSerif(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Top Events Carousel
                          SizedBox(
                            height: 220,
                            child: ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: topEventDescriptions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      final url =
                                          topEventDescriptions[index]['url'];
                                          
                                      if (url != null) {
                                        _launchUrl(url);
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.asset(
                                            topEventDescriptions[index]['img'],
                                            width: screenWidth * 1,
                                            height: screenHeight * 0.275,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black.withOpacity(0.4),
                                                  Colors.transparent
                                                ],
                                                begin: Alignment.bottomCenter,
                                                end: Alignment.topCenter,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.02),

                          // Game Cards Section
                          Text(
                            "Games",
                            style: GoogleFonts.breeSerif(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          // Game Cards Grid
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            children: const [
                              GameCard(
                                imagePath: 'assets/cutout/bgmi.png',
                                color: Color.fromRGBO(160, 4, 168, 0.721),
                                title: 'BGMI',
                              ),
                              GameCard(
                                imagePath: 'assets/cutout/cod.png',
                                color: Color.fromRGBO(187, 189, 188, 1),
                                title: 'Call Of Duty',
                              ),
                              GameCard(
                                imagePath: 'assets/cutout/raven.png',
                                color: Color.fromARGB(255, 88, 248, 237),
                                title: 'FORTNITE',
                              ),
                              GameCard(
                                imagePath: 'assets/cutout/apex.png',
                                color: Color.fromARGB(255, 11, 134, 191),
                                title: 'APEX    LEGENDS',
                              ),
                              GameCard(
                                imagePath: 'assets/cutout/indus.png',
                                color: Colors.red,
                                title: 'INDUS BATTLE ROYALE',
                              ),
                              GameCard(
                                imagePath: 'assets/cutout/freefire.png',
                                color: Color.fromARGB(255, 255, 59, 255),
                                title: 'FREEFIRE',
                              ),
                              GameCard(
                                imagePath: 'assets/cutout/pubgw.png',
                                color: Color.fromARGB(255, 246, 154, 6),
                                title: 'PUBG',
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Top Players Section
                          Text(
                            "Top Players",
                            style: GoogleFonts.breeSerif(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),

                          SizedBox(height: screenHeight * 0.018),
                          const TopPlayersSection(),
                          //betting guide Content
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.02),
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome to EBETZ!',
                                  style: GoogleFonts.breeSerif(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.015),
                                Text(
                                  '• Learn the Basics :',
                                  style: GoogleFonts.cairo(
                                    color: Colors.orangeAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Understand how eSports betting works, including different bet types and odds.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  '• Understand Odds :',
                                  style: GoogleFonts.cairo(
                                    color: Colors.orangeAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Familiarize yourself with how odds are calculated and what they mean for your bets.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  '• Responsible Betting :',
                                  style: GoogleFonts.cairo(
                                    color: Colors.orangeAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Always bet within your means. Set limits and never chase losses.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  '• Stay Informed :',
                                  style: GoogleFonts.cairo(
                                    color: Colors.orangeAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Keep up with the latest news and updates in the eSports world to make informed bets.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  '• Enjoy the Experience :',
                                  style: GoogleFonts.cairo(
                                    color: Colors.orangeAccent,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Betting should be fun and exciting. Enjoy the thrill of the game!',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
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
    );
  }
}

class GameCard extends StatelessWidget {
  final String imagePath;
  final Color color;
  final String title;

  const GameCard({
    required this.imagePath,
    required this.color,
    required this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
        onTap: () {
          // Navigate to the tournaments page for the selected game
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TournamentsPage(
                gameName: title,
                tournamentName: '',
              ),
            ),
          );
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main card container
            Container(
              height: screenHeight * 0.18,
              width: screenHeight * 0.3,
              decoration: BoxDecoration(
                color: color.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 1.5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: RotatedBox(
                  quarterTurns: -1, // Rotates the text -90 degrees clockwise
                  child: Text(
                    title,
                    style: GoogleFonts.ubuntu(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            // Floating image
            Positioned(
              top: -screenHeight * 0.030,
              right: -screenWidth * 0.08,
              child: SizedBox(
                width: screenWidth * 0.45,
                height: screenHeight * 0.21,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ));
  }
}
