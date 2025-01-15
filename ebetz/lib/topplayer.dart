import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'player_stats.dart';

class TopPlayersSection extends StatefulWidget {
  const TopPlayersSection({Key? key}) : super(key: key);

  @override
  _TopPlayersSectionState createState() => _TopPlayersSectionState();
}

class _TopPlayersSectionState extends State<TopPlayersSection> {
  late Future<List<Map<String, dynamic>>> _topPlayersFuture;

  @override
  void initState() {
    super.initState();
    // Initialize the Future to fetch players
    _topPlayersFuture = fetchTopPlayers();
  }

  /// Fetches the top players from Firestore
  Future<List<Map<String, dynamic>>> fetchTopPlayers() async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      // Transform the Firestore data into a list of maps
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'username': data['username'],
          'matchesPlayed': data['matchPlayed'],
          'matchesWon': data['matchesWin'],
        };
      }).toList();
    } catch (e) {
      print("Error fetching players: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _topPlayersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return const Center(
            child: Text(
              "Error loading players.",
              style: TextStyle(color: Colors.white),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No players found.",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final players = snapshot.data!;

        return SizedBox(
          height: screenHeight * 0.15,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: players.length,
            itemBuilder: (context, index) {
              final player = players[index];

              return GestureDetector(
                onTap: () {
                  // Navigate to PlayerStatsScreen with data
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlayerStatsScreen(
                        playerUid: player['id'], // Pass player ID
                        userName: player['username'], // Pass username
                        profileImage: 'assets/images/player${index + 1}.jpg',
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Column(
                    children: [
                      // Circular Profile Image
                      Container(
                        width: screenWidth * 0.2,
                        height: screenWidth * 0.2,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/player${index + 1}.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Username
                      Text(
                        player['username'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
