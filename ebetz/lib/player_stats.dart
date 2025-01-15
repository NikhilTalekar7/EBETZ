import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayerStatsScreen extends StatefulWidget {
  final String playerUid; // UID of the player whose stats are being viewed.
  final String userName;
  final String profileImage;

  const PlayerStatsScreen({
    Key? key,
    required this.playerUid,
    required this.userName,
    required this.profileImage,
  }) : super(key: key);

  @override
  _PlayerStatsScreenState createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends State<PlayerStatsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  int followers = 0;
  int following = 0;
  int matchesPlayed = 0;
  int matchesWon = 0;
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    fetchPlayerStats();
    checkIfFollowing();
  }

  Future<void> fetchPlayerStats() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.playerUid).get();

      if (userDoc.exists) {
        setState(() {
          followers = userDoc['followers'] ?? 0;
          following = userDoc['following'] ?? 0;
          matchesPlayed = userDoc['matchPlayed'] ?? 0;
          matchesWon = userDoc['matchesWin'] ?? 0;
        });
      }
    } catch (e) {
      print("Error fetching player stats: $e");
    }
  }

  Future<void> checkIfFollowing() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        DocumentSnapshot currentUserDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (currentUserDoc.exists) {
          List<dynamic> followingList =
              currentUserDoc['followingList'] ?? []; // Assuming a list is maintained
          setState(() {
            isFollowing = followingList.contains(widget.playerUid);
          });
        }
      } catch (e) {
        print("Error checking follow status: $e");
      }
    }
  }

  Future<void> toggleFollow() async {
    User? currentUser = _auth.currentUser;
    if (currentUser != null) {
      try {
        WriteBatch batch = _firestore.batch();

        DocumentReference currentUserRef =
            _firestore.collection('users').doc(currentUser.uid);
        DocumentReference targetUserRef =
            _firestore.collection('users').doc(widget.playerUid);

        if (isFollowing) {
          // Unfollow logic
          batch.update(currentUserRef, {
            'following': FieldValue.increment(-1),
            'followingList': FieldValue.arrayRemove([widget.playerUid]),
          });
          batch.update(targetUserRef, {
            'followers': FieldValue.increment(-1),
          });
        } else {
          // Follow logic
          batch.update(currentUserRef, {
            'following': FieldValue.increment(1),
            'followingList': FieldValue.arrayUnion([widget.playerUid]),
          });
          batch.update(targetUserRef, {
            'followers': FieldValue.increment(1),
          });
        }

        await batch.commit();

        setState(() {
          isFollowing = !isFollowing;
          followers += isFollowing ? 1 : -1;
        });
      } catch (e) {
        print("Error toggling follow status: $e");
      }
    }
  }

 @override
Widget build(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  User? currentUser = _auth.currentUser;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: const Color.fromARGB(255, 10, 10, 35),
      elevation: 0,
      toolbarHeight: 30,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Stack(
      children: [
        // Gradient Background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0A0A23),
                Color(0xFF35345C),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),

        // Main Content
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Profile Section
            Center(
              child: Column(
                children: [
                  // Profile Image
                  Container(
                    width: screenWidth * 0.4,
                    height: screenWidth * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        widget.profileImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Username
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  // Followers and Following
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _statText("Followers", followers),
                      const SizedBox(width: 40),
                      _statText("Following", following),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Follow Button: Only show if the logged-in user is viewing another user's profile
            if (currentUser != null && currentUser.uid != widget.playerUid)
              ElevatedButton(
                onPressed: toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowing ? Colors.red : Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 10,
                  ),
                ),
                child: Text(
                  isFollowing ? "Unfollow" : "Follow",
                  style: const TextStyle(
                      fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 40),

            // Stats Section with Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statCard(
                    title: "Matches Played",
                    value: matchesPlayed,
                    width: screenWidth * 0.4,
                  ),
                  _statCard(
                    title: "Matches Won",
                    value: matchesWon,
                    width: screenWidth * 0.4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  // Reusable Widget for Stats Card
  Widget _statCard({
    required String title,
    required int value,
    required double width,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "$value",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
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
}
