import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebetz/login1.dart';
import 'package:ebetz/match_details_page.dart';
import 'package:ebetz/matches.dart';
import 'package:ebetz/userfeedback.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Betting Admin Dashboard',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.cyanAccent,
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
        ),
      ),
      home: const BettingAdminDashboard(),
    );
  }
}

class BettingAdminDashboard extends StatelessWidget {
  const BettingAdminDashboard({super.key});

  Future<int> _fetchTotalRevenueFromCompletedTournaments() async {
    final firestore = FirebaseFirestore.instance;

    try {
      // Query tournaments with 'Completed' status
      final completedTournamentsSnapshot = await firestore
          .collection('tournaments')
          .where('status', isEqualTo: 'Completed')
          .get();

      // Calculate total revenue from the revenue field
      final totalRevenue =
          completedTournamentsSnapshot.docs.fold<int>(0, (sum, doc) {
        final revenue =
            (doc.data()['revenue'] ?? 0) as num; // Safely cast to num
        return sum + revenue.toInt(); // Ensure integer value
      });

      return totalRevenue;
    } catch (e) {
      debugPrint("Error fetching revenue: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard',
            style: GoogleFonts.breeSerif(
                color: Colors.white, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: _buildSideNav(context),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.03), // Responsive padding
        child: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('tournaments').snapshots(),
          builder: (context, snapshot) {
            int totalBets = 0;
            int upcomingBets = 0;
            int activeBets = 0;
            int completedBets = 0;
            // if (snapshot.connectionState == ConnectionState.waiting) {
            //   return const Center(child: CircularProgressIndicator());
            // }

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final tournaments = snapshot.data!.docs;

              // Calculate required counts
              totalBets = tournaments.length;
              upcomingBets = tournaments
                  .where((doc) => doc["status"] == "Upcoming")
                  .length;
              activeBets =
                  tournaments.where((doc) => doc["status"] == "Live").length;
              completedBets = tournaments
                  .where((doc) => doc["status"] == "Completed")
                  .length;
            }

            return GridView.count(
              crossAxisCount: (screenWidth > 600)
                  ? 3
                  : 2, // Adjust grid based on screen width
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildDashboardCard('Total Bets', totalBets.toString(),
                    Colors.blue, FontAwesomeIcons.coins),
                StreamBuilder<int>(
                  stream: Stream.fromFuture(
                      _fetchTotalRevenueFromCompletedTournaments()),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildDashboardCard(
                        'Revenue',
                        'Loading...',
                        Colors.green,
                        FontAwesomeIcons.indianRupeeSign,
                      );
                    }

                    final totalRevenue = snapshot.data ?? 0;

                    return _buildDashboardCard(
                      'Revenue',
                      '\u20B9 $totalRevenue',
                      Colors.green,
                      FontAwesomeIcons.indianRupeeSign,
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .snapshots(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildDashboardCard('Active Users', '...',
                          Colors.orange, FontAwesomeIcons.users);
                    }

                    final activeUsers = userSnapshot.data?.docs.length ?? 0;

                    return _buildDashboardCard(
                        'Active Users',
                        activeUsers.toString(),
                        Colors.orange,
                        FontAwesomeIcons.users);
                  },
                ),
                _buildDashboardCard('Upcoming Bet', upcomingBets.toString(),
                    Colors.red, FontAwesomeIcons.calendarAlt),
                _buildDashboardCard('Active Bet', activeBets.toString(),
                    Colors.amber, FontAwesomeIcons.solidFlag),
                _buildDashboardCard('Completed Bet', completedBets.toString(),
                    Colors.teal, FontAwesomeIcons.checkCircle),
              ],
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCreateBetButton(context),
    );
  }

  Widget _buildSideNav(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 140,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.cyanAccent, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                ),
              ],
            ),
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.admin_panel_settings,
                        color: Colors.black, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Admin Panel',
                    style: GoogleFonts.breeSerif(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Dashboard', context),
          _buildDrawerItem(Icons.sports_esports, 'Matches', context),
          _buildDrawerItem(Icons.feedback_outlined, 'Users Feedback', context),
          _buildDrawerItem(Icons.logout, 'Logout', context),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.cyanAccent),
      title: Text(title, style: GoogleFonts.cairo(color: Colors.white)),
      onTap: () async {
        if (title == 'Matches') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        }
        if (title == 'Dashboard') {
          Navigator.pop(context);
        }
        if (title == 'Users Feedback') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UserFeedbackPage()),
          );
        }
        if (title == 'Logout') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear(); // Clear all stored preferences

          // Navigate back to login screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const LoginForm(isLogin: false)),
            (route) => false,
          );
        }
      },
    );
  }

  Widget _buildDashboardCard(
      String title, String value, Color color, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 36),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    value,
                    key: ValueKey<String>(value),
                    style: GoogleFonts.cairo(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateBetButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () async {
        try {
          // Fetch Firestore data before navigation
          QuerySnapshot<Map<String, dynamic>> snapshot =
              await FirebaseFirestore.instance.collection('tournaments').get();

          // Map the fetched data, including tournament ID
          final matchDetails = snapshot.docs.map((doc) {
            final data = doc.data();
            return {
              "tournamentId": doc.id, // Extract tournamentId from document ID
              "tournamentName": data["tournamentName"],
              "status": data["status"] ?? "Upcoming",
              "prizePool": data["prizePool"],
              "matchFee": data["matchFee"],
            };
          }).toList();

          // Ensure you pass a valid tournamentId (you can use the first match for demonstration)
          if (matchDetails.isNotEmpty) {
            final firstMatch = matchDetails.first;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MatchDetailsPage(
                  matchDetails: matchDetails,
                  tournamentId:
                      firstMatch["tournamentId"], // Pass the first match ID
                ),
              ),
            );
          }
        } catch (e) {
          print("Error: $e");
        }
      },
      label: Text('Update Bet',
          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold)),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      foregroundColor: const Color.fromARGB(255, 6, 5, 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      splashColor: const Color.fromARGB(255, 48, 38, 37).withOpacity(0.3),
    );
  }
}
