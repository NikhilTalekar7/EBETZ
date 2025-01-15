import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebetz/teamlist.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TournamentsPage extends StatelessWidget {
  final String gameName;
  final String tournamentName;

  const TournamentsPage(
      {required this.gameName, required this.tournamentName, super.key});

  Future<List<Map<String, dynamic>>> fetchTournaments(String gameName) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    QuerySnapshot snapshot = await _firestore
        .collection('tournaments')
        .where('gameName', isEqualTo: gameName)
        .where('status', isEqualTo: 'Upcoming')
        .get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> joinTournament(
      BuildContext context, String tournamentId, String tournamentName) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to join a tournament.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Fetch user's wallet balance
      DocumentSnapshot userSnapshot =
          await firestore.collection('users').doc(userId).get();

      if (!userSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found. Please log in again.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;
      final walletBalance = userData['Account_Balance'] ?? 0.0;

      // Fetch tournament's entry fee
      DocumentSnapshot tournamentSnapshot =
          await firestore.collection('tournaments').doc(tournamentId).get();

      if (!tournamentSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tournament not found.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final tournamentData = tournamentSnapshot.data() as Map<String, dynamic>;
      final entryFee = tournamentData['matchFee'] ?? 0.0;

      // Check if wallet balance is sufficient
      if (walletBalance < entryFee) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Insufficient balance. Please add funds to your wallet.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Deduct the entry fee and update wallet balance
      final updatedBalance = walletBalance - entryFee;
      await firestore.collection('users').doc(userId).update({
        'Account_Balance': updatedBalance,
      });

      // Update the tournament document

      await firestore.collection('tournaments').doc(tournamentId).update({
        'joinedUsers': FieldValue.arrayUnion([userId]),
      });

      await firestore.collection('users').doc(userId).update({
        'joinedTournaments': FieldValue.arrayUnion([tournamentId]),
      });
      final int matchPlayed = userData['matchPlayed'] ?? 0;
      await firestore.collection('users').doc(userId).update({
        'matchPlayed': matchPlayed + 1,
      });


      // Navigate to TeamListPage with tournament name
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamListPage(
            tournamentId: tournamentId,
            gameName: gameName,
            tournamentName: tournamentName, // Pass tournament name
          ),
        ),
      );
    } catch (e) {
      print('Error joining tournament: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to join tournament.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '$gameName Tournaments',
          style: GoogleFonts.breeSerif(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: Color.fromRGBO(53, 52, 92, 1),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(53, 52, 92, 1),
                Color.fromRGBO(0, 0, 41, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchTournaments(gameName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_dissatisfied,
                          color: Colors.grey[400], size: 80),
                      const SizedBox(height: 16),
                      Text(
                        'No Tournament Found',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final tournaments = snapshot.data!;
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                itemCount: tournaments.length,
                itemBuilder: (context, index) {
                  final tournament = tournaments[index];
                  final tournamentId = tournament['tournamentId'];
                  //final List<> joinedUsers = (tournament['joinedUsers'] ?? []) as List<dynamic>;
                  final userId = FirebaseAuth.instance.currentUser?.uid;

                  final List<String> joinedUsers =
                      List<String>.from(tournament['joinedUsers'] ?? []);

                  final Timestamp? startTimeStamp = tournament['startTime'];
                  String formattedDateTime = "Date/Time not available";
                  if (startTimeStamp != null) {
                    final DateTime startTime = startTimeStamp.toDate();
                    formattedDateTime =
                        DateFormat('yyyy-MM-dd | hh:mm a').format(startTime);
                  }

                  final bool isUserJoined = joinedUsers.contains(userId);

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.grey[800]!,
                          Color.fromRGBO(53, 52, 92, 1)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(4, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  height: 2,
                                  width: 100,
                                  color: Colors.blueAccent.withOpacity(0.7),
                                ),
                                Stack(
                                  children: [
                                    Text(
                                      tournament['tournamentName'] ??
                                          "Tournament Name",
                                      style: GoogleFonts.breeSerif(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        foreground: Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color =
                                              Color.fromARGB(255, 18, 68, 154)
                                                  .withOpacity(0.7),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      tournament['tournamentName'] ??
                                          "Tournament Name",
                                      style: GoogleFonts.breeSerif(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            startTimeStamp != null
                                ? StreamBuilder<int>(
                                    stream: Stream.periodic(
                                        const Duration(seconds: 1), (tick) {
                                      final now = DateTime.now();
                                      final startTime = startTimeStamp
                                          .toDate()
                                          .millisecondsSinceEpoch;
                                      final remaining = startTime -
                                          now.millisecondsSinceEpoch;
                                      return remaining > 0 ? remaining : 0;
                                    }),
                                    builder: (context, timerSnapshot) {
                                      if (!timerSnapshot.hasData) {
                                        return const Text(
                                          "Loading timer...",
                                          style: TextStyle(color: Colors.white),
                                        );
                                      }
                                      final remaining = timerSnapshot.data!;
                                      if (remaining == 0) {
                                        return const Text(
                                          "Tournament Started",
                                          style: TextStyle(
                                            color: Colors.redAccent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      }

                                      final days =
                                          remaining ~/ (1000 * 60 * 60 * 24);
                                      final hours =
                                          (remaining ~/ (1000 * 60 * 60)) % 24;
                                      final minutes =
                                          (remaining ~/ (1000 * 60)) % 60;
                                      final seconds = (remaining ~/ 1000) % 60;

                                      return Text(
                                        "Starts In: ${days}d ${hours}h ${minutes}m ${seconds}s",
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    },
                                  )
                                : Text(
                                    "Starts On: $formattedDateTime",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    const FaIcon(
                                      FontAwesomeIcons.trophy,
                                      size: 15,
                                      color: Colors.orangeAccent,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Prize Pool: ₹${tournament['prizePool'] ?? 0}",
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    // Icon(Icons.currency_rupee,
                                    //     color: Colors.green, size: 15),
                                    FaIcon(FontAwesomeIcons.moneyBill,
                                        color: Colors.greenAccent, size: 16),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Entry Fee: ₹${tournament['matchFee'] ?? 0}",
                                      style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Players Joined: ${joinedUsers.length}/${tournament['numPlayers'] ?? 1}",
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Icon(Icons.people,
                                          color: Colors.blueAccent, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: (joinedUsers.length /
                                          (tournament['numPlayers'] ?? 1)
                                              .toDouble()),
                                      backgroundColor: Colors.grey[700],
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.greenAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Show Join Button Only Before Tournament Starts
                            StreamBuilder<int>(
                              stream: Stream.periodic(
                                  const Duration(seconds: 1), (tick) {
                                final now = DateTime.now();
                                final startTime = startTimeStamp
                                        ?.toDate()
                                        .millisecondsSinceEpoch ??
                                    0;
                                return startTime - now.millisecondsSinceEpoch;
                              }),
                              builder: (context, timerSnapshot) {
                                if (!timerSnapshot.hasData ||
                                    timerSnapshot.data! <= 0) {
                                  return const SizedBox.shrink();
                                }

                                final bool isTournamentFull =
                                    joinedUsers.length >=
                                        (tournament['numPlayers'] ?? 0);

                                if (isTournamentFull) {
                                  return const Text(
                                    'Tournament is Full',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }

                                if (isUserJoined) {
                                  return Text(
                                    "You already joined this tournament",
                                    style: TextStyle(
                                      color: Colors.yellow[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }

                                return ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromRGBO(69, 66, 163, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    joinTournament(context, tournamentId,
                                        tournament['tournamentName']);
                                  },
                                  icon: const Icon(
                                    Icons.sports_esports,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Join Now',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                );
                              },
                            ),
                            SizedBox(
                              height: screenHeight * 0.025,
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          )),
    );
  }
}