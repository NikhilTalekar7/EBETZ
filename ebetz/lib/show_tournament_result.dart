import 'package:ebetz/home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'navigation.dart';
import 'user_my_matches.dart';

class TournamentResultsPage extends StatelessWidget {
  final String tournamentName;
  final String tournamentId;

  const TournamentResultsPage({
    super.key,
    required this.tournamentName,
    required this.tournamentId,
  });

  // Update Total Points for All Users
  Future<void> _updateTotalPointsForTournament() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch all users who joined the tournament
      final joinedUsersSnapshot = await firestore
          .collection('super_teams')
          .where('tournamentName', isEqualTo: tournamentName)
          .get();

      // Fetch points table for the tournament
      final pointsTableSnapshot = await firestore
          .collection('points_table')
          .where('tournamentName', isEqualTo: tournamentName)
          .get();

      // Create a map of teamName to points for easy lookup
      final Map<String, int> teamPoints = {
        for (var doc in pointsTableSnapshot.docs)
          doc['teamName']: (doc['points'] as num).toInt(),
      };

      // Update totalPoints for each user
      for (var userDoc in joinedUsersSnapshot.docs) {
        final userData = userDoc.data();
        final List<dynamic> selectedTeams = userData['selectedTeams'];
        final String? superTeam = userData['superTeam'];

        int totalPoints = 0;

        for (String team in selectedTeams) {
          final teamPointsValue = teamPoints[team] ?? 0;
          totalPoints += teamPointsValue;

          // Double points for the super team
          if (team == superTeam) {
            totalPoints += teamPointsValue;
          }
        }

        // Update totalPoints in Firestore
        await userDoc.reference.update({'totalPoints': totalPoints});
      }
    } catch (e) {
      debugPrint("Error updating total points: $e");
    }
  }

  // Fetch Updated Tournament Results
  Future<List<Map<String, dynamic>>> _fetchTournamentResults() async {
    final firestore = FirebaseFirestore.instance;

    // Ensure totalPoints are updated before fetching
    await _updateTotalPointsForTournament();

    // Fetch all users who joined the tournament
    final joinedUsersSnapshot = await firestore
        .collection('super_teams')
        .where('tournamentName', isEqualTo: tournamentName)
        .get();

    // Process and sort results by totalPoints
    List<Map<String, dynamic>> results = [];
    for (var userDoc in joinedUsersSnapshot.docs) {
      final userData = userDoc.data();

      results.add({
        'username': userData['username'],
        'selectedTeams': userData['selectedTeams'],
        'superTeam': userData['superTeam'],
        'totalPoints': userData['totalPoints'] ?? 0,
      });
    }

    return results
      ..sort((a, b) => b['totalPoints'].compareTo(a['totalPoints']));
  }

  Future<void> _updateWinnerBalanceAndFlag(String winnerUsername,
      List<Map<String, dynamic>> results, int prizePool) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final batch = firestore.batch();

      // Determine the highest score
      final highestScore = results.isNotEmpty ? results[0]['totalPoints'] : 0;

      // Find all players with the highest score
      final tiedPlayers = results
          .where((result) => result['totalPoints'] == highestScore)
          .toList();
      final prizePerWinner =
          prizePool / tiedPlayers.length; // Divide prize pool equally

      for (var result in tiedPlayers) {
        final username = result['username'];

        // Fetch the user's document reference
        final userSnapshot = await firestore
            .collection('users')
            .where('username', isEqualTo: username)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          final userDoc = userSnapshot.docs.first;
          final userRef = userDoc.reference;

          // Fetch current Account_Balance and matchesWin
          final currentBalance = userDoc['Account_Balance'] ?? 0;
          final matchesWin = userDoc['matchesWin'] ?? 0;

          // Update balance and matchesWin
          final updatedBalance = currentBalance + prizePerWinner;
          batch.update(userRef, {
            'Account_Balance': updatedBalance,
            'matchesWin': matchesWin + 1,
          });
        }
      }

      // Commit the batch write
      await batch.commit();

      // Set the balanceUpdated flag to true
      await _setBalanceUpdated();
      debugPrint("Winner's balance updated and flag set successfully.");
    } catch (e) {
      debugPrint("Error updating winner's balance: $e");
    }
  }

// Fetch Prize Pool from Tournament Collection
  Future<int> _fetchPrizePool() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final tournamentSnapshot = await firestore
          .collection('tournaments')
          .where('tournamentName', isEqualTo: tournamentName)
          .limit(1)
          .get();

      if (tournamentSnapshot.docs.isNotEmpty) {
        final prizePool = tournamentSnapshot.docs.first['prizePool'];
        return prizePool != null ? (prizePool as num).toInt() : 0;
      }
      return 0;
    } catch (e) {
      debugPrint("Error fetching prize pool: $e");
      return 0;
    }
  }

  // // Update Winner's Account Balance
  // Future<void> _updateWinnerBalance(String winnerUsername,
  //     List<Map<String, dynamic>> results, int prizePool) async {
  //   final firestore = FirebaseFirestore.instance;
  //   try {
  //     final batch = firestore.batch();

  //     // Determine the highest score
  //     final highestScore = results.isNotEmpty ? results[0]['totalPoints'] : 0;

  //     // Find all players with the highest score
  //     final tiedPlayers = results
  //         .where((result) => result['totalPoints'] == highestScore)
  //         .toList();
  //     final prizePerWinner =
  //         prizePool / tiedPlayers.length; // Divide prize pool equally

  //     for (var result in results) {
  //       final username = result['username'];
  //       // Fetch the user's document reference
  //       final userSnapshot = await firestore
  //           .collection('users')
  //           .where('username', isEqualTo: username)
  //           .limit(1)
  //           .get();

  //       if (userSnapshot.docs.isNotEmpty) {
  //         final userDoc = userSnapshot.docs.first;
  //         final userRef = userDoc.reference;

  //         // Fetch current matchesWin and matchesLose values
  //         final matchesWin = userDoc['matchesWin'] ?? 0;
  //         final matchesLose = userDoc['matchesLoss'] ?? 0;
  //         final currentBalance = userDoc['Account_Balance'] ?? 0;

  //         // Prepare the updates
  //         final isWinner = result['totalPoints'] == highestScore;
  //         debugPrint("Updating user ${result['username']}, Winner: $isWinner");

  //         if (isWinner) {
  //           final updatedBalance = currentBalance + prizePerWinner;
  //           batch.update(userRef, {
  //           'Account_Balance': updatedBalance,
  //           'matchesWin': matchesWin + 1,
  //           'winnerCount': FieldValue.increment(1), // Increment winner count
  //         });
  //         } else {
  //           batch.update(userRef, {
  //             'matchesLoss': matchesLose + 1, // Increment losses
  //             'matchesPlayed':
  //                 matchesWin + matchesLose + 1, // Update total matches played
  //           });
  //         }
  //       }
  //     }

  //     // Commit the batch write
  //     await batch.commit();
  //     debugPrint("Winner's stats and other users' stats updated successfully.");
  //   } catch (e) {
  //     debugPrint("Error updating stats: $e");
  //   }
  // }

  Future<bool> _hasBalanceBeenUpdated() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final tournamentSnapshot = await firestore
          .collection('tournaments')
          .where('tournamentName', isEqualTo: tournamentName)
          .limit(1)
          .get();

      if (tournamentSnapshot.docs.isNotEmpty) {
        final tournamentDoc = tournamentSnapshot.docs.first;
        final balanceUpdated = tournamentDoc['balanceUpdated'] ?? false;
        return balanceUpdated;
      }
      return false;
    } catch (e) {
      debugPrint("Error checking balance update status: $e");
      return false;
    }
  }

  Future<void> _setBalanceUpdated() async {
    final firestore = FirebaseFirestore.instance;

    try {
      final tournamentSnapshot = await firestore
          .collection('tournaments')
          .where('tournamentName', isEqualTo: tournamentName)
          .limit(1)
          .get();

      if (tournamentSnapshot.docs.isNotEmpty) {
        final tournamentDoc = tournamentSnapshot.docs.first;
        await tournamentDoc.reference.update({'balanceUpdated': true});
        debugPrint("Balance updated flag set to true.");
      }
    } catch (e) {
      debugPrint("Error setting balanceUpdated flag: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(0, 0, 41, 1),
          elevation: 0,
          centerTitle: true,
          title: Text(
            "$tournamentName - Results",
            style: GoogleFonts.breeSerif(
              fontWeight: FontWeight.w700,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const UserMyMatches()),
                (route) =>
                    false, // Predicate to remove routes (return false to clear all)
              );
            },
          ),
        ),
        body: Container(
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
          child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchTournamentResults(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No results available.",
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                  );
                }

                final results = snapshot.data!;
                return FutureBuilder<int>(
                  future: _fetchPrizePool(),
                  builder: (context, prizePoolSnapshot) {
                    if (prizePoolSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!prizePoolSnapshot.hasData) {
                      return const Center(
                          child: Text("Error fetching prize pool"));
                    }

                    final prizePool = prizePoolSnapshot.data!;

                    // Determine the winner
                    // final winnerUsername =
                    //     results.isNotEmpty ? results[0]['username'] : '';

                    // Determine the winner
                    // final winnerUsername =
                    //     results.isNotEmpty ? results[0]['username'] : '';

                    // // Update the winner's balance (this could be done after the results are displayed)
                    // if (winnerUsername.isNotEmpty) {
                    //   _updateWinnerBalance(winnerUsername, results, prizePool);
                    // }

                    return FutureBuilder<bool>(
                      future: _hasBalanceBeenUpdated(),
                      builder: (context, balanceUpdatedSnapshot) {
                        if (balanceUpdatedSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final balanceUpdated =balanceUpdatedSnapshot.data ?? false;

                        // // If the balance has not been updated, update it
                        // if (!balanceUpdated && results.isNotEmpty) {
                        //   final winnerUsername = results[0]['username'];
                        //   _updateWinnerBalance(
                        //       winnerUsername, results, prizePool);
                        //   _setBalanceUpdated(); // Set the flag to true
                        // }

                        if (!balanceUpdated && results.isNotEmpty) {
                          final highestScore = results[0]['totalPoints'];
                          final tiedPlayers = results
                              .where((result) =>
                                  result['totalPoints'] == highestScore)
                              .toList();
                          _updateWinnerBalanceAndFlag("", tiedPlayers,
                              prizePool); // Call without duplicating
                        }
                        return ListView.builder(
                          padding: const EdgeInsets.all(16.0),
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            final result = results[index];
                            final selectedTeams = result['selectedTeams'];
                            final superTeam = result['superTeam'];
                            final totalPoints = result['totalPoints'];
                            //final isWinner = index == 0;

                            // final isScoreEqual = index > 0 &&
                            //     totalPoints == results[0]['totalPoints'];

                            // final prizeAmount = isScoreEqual
                            //     ? prizePool / 2
                            //     // Divide prize equally if scores are tied
                            //     : (index == 0 ? prizePool : 0);
                            // Check if the current player's points are equal to the highest score
                            final highestScore = results.isNotEmpty
                                ? results[0]['totalPoints']
                                : 0;
                            final isScoreEqual = totalPoints == highestScore;

                            // Determine prize distribution
                            final prizeAmount = isScoreEqual
                                ? prizePool /
                                    results
                                        .where((r) =>
                                            r['totalPoints'] == highestScore)
                                        .length
                                : 0; // Divide prize equally among tied players
                            return Card(
                              color: Colors.grey[900],
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                side: const BorderSide(
                                    color: Colors.white, width: 1.5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Avatar Section
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.tealAccent,
                                          child: Text(
                                            result['username'][0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // User Info Section
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                result['username'],
                                                style: const TextStyle(
                                                  color: Colors.tealAccent,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                "Teams: ${selectedTeams.join(', ')}",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Super Team: $superTeam",
                                                style: const TextStyle(
                                                  color: Colors.amberAccent,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Points Section
                                        Column(
                                          children: [
                                            Text(
                                              "$totalPoints",
                                              style: const TextStyle(
                                                color: Colors.lightGreenAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                            const Text(
                                              "Points",
                                              style: TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    // Prize/Message Section
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          isScoreEqual
                                              ? "WIN: ₹${prizeAmount.toStringAsFixed(2)}"
                                              : (index == 0
                                                  ? "WIN: ₹$prizePool"
                                                  : "Better Luck Next Time."),
                                          style: TextStyle(
                                            color: isScoreEqual
                                                ? Colors.orangeAccent
                                                : (index == 0
                                                    ? Colors.yellow
                                                    : Colors.redAccent),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        // Winner or Message
                                        // isWinner
                                        //     ? Text(
                                        //         "You Win: ₹$prizePool",
                                        //         style: const TextStyle(
                                        //           color: Colors.yellow,
                                        //           fontWeight: FontWeight.bold,
                                        //           fontSize: 18,
                                        //         ),
                                        //       )
                                        //     : const Text(
                                        //         "Better Luck Next Time.",
                                        //         style: TextStyle(
                                        //           color: Colors.redAccent,
                                        //           fontWeight: FontWeight.bold,
                                        //           fontSize: 16,
                                        //         ),
                                        //       ),
                                        // View Points Button
                                        PopupMenuButton<String>(
                                          offset: const Offset(0,
                                              40), // Adjust dropdown position
                                          color: Colors.grey[
                                              800], // Dropdown background color
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Rounded dropdown
                                          ),
                                          itemBuilder: (context) {
                                            return selectedTeams
                                                .map<PopupMenuItem<String>>(
                                                    (team) {
                                              return PopupMenuItem<String>(
                                                value: team,
                                                child: FutureBuilder<int>(
                                                  future: FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                          'points_table')
                                                      .where('tournamentName',
                                                          isEqualTo:
                                                              tournamentName)
                                                      .where('teamName',
                                                          isEqualTo: team)
                                                      .get()
                                                      .then((snapshot) =>
                                                          snapshot.docs
                                                                  .isNotEmpty
                                                              ? snapshot.docs
                                                                          .first[
                                                                      'points']
                                                                  as int
                                                              : 0),
                                                  builder: (context,
                                                      pointsSnapshot) {
                                                    if (pointsSnapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return const Text(
                                                          "Loading...",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white));
                                                    }
                                                    final points =
                                                        pointsSnapshot.data ??
                                                            0;
                                                    final isSuperTeam =
                                                        team == superTeam;
                                                    final displayPoints =
                                                        isSuperTeam
                                                            ? points * 2
                                                            : points;

                                                    return Text(
                                                      isSuperTeam
                                                          ? "$team (Super Team): $displayPoints points"
                                                          : "$team: $displayPoints points",
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    );
                                                  },
                                                ),
                                              );
                                            }).toList();
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors
                                                  .tealAccent, // Button color
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            child: const Text(
                                              "View Points",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              }),
        ));
  }
}
