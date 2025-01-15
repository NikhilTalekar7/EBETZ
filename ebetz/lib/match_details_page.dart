import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pointstable.dart';
import 'dart:async';

class MatchDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> matchDetails;
  final String tournamentId;

  const MatchDetailsPage(
      {super.key, required this.matchDetails, required this.tournamentId});

  @override
  State createState() => _MatchDetailsPageState();
}

class _MatchDetailsPageState extends State<MatchDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchMatchDetails();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _updateMatchStatus();
      });
    });
    log("Tournament ID: ${widget.tournamentId}");
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _updateMatchStatus() {
    for (var match in widget.matchDetails) {
      final startTime = match["startTime"] as DateTime?;
      if (startTime != null) {
        final now = DateTime.now();
        if (startTime.isBefore(now) && match["status"] == "Upcoming") {
          // Update the status only after the countdown has ended
          setState(() {
            match["status"] = "Live";
          });

          // Optional: Sync the status update with Firestore
          FirebaseFirestore.instance
              .collection('tournaments')
              .doc(widget.tournamentId)
              .update({
            "status": "Live",
          });
        }
      }
    }
  }

  // Future<void> _fetchMatchDetails() async {
  //   try {
  //     // Fetch all documents from the 'tournaments' collection
  //     QuerySnapshot<Map<String, dynamic>> snapshot =
  //         await FirebaseFirestore.instance.collection('tournaments').get();

  //     final fetchedDetails = snapshot.docs.map((doc) {
  //       final data = doc.data();
  //       return {
  //         "tournamentName": data["tournamentName"],
  //         "startTime": (data["startTime"] as Timestamp?)?.toDate(),
  //         "status": data["status"] ?? "Upcoming",
  //         "prizePool": data["prizePool"],
  //         "matchFee": data["matchFee"],
  //       };
  //     }).toList();

  //     // Update the matchDetails list with Firestore data
  //     setState(() {
  //       widget.matchDetails.clear();
  //       widget.matchDetails.addAll(fetchedDetails);
  //     });
  //   } catch (e) {
  //     print('Error fetching match details: $e');
  //   }
  // }

  Future<void> _fetchMatchDetails() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('tournaments').get();

      final fetchedDetails = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "tournamentId": doc.id, // Include the Firestore document ID
          "tournamentName": data["tournamentName"],
          "startTime": (data["startTime"] as Timestamp?)?.toDate(),
          "status": data["status"] ?? "Upcoming",
          "prizePool": data["prizePool"],
          "matchFee": data["matchFee"],
        };
      }).toList();

      setState(() {
        widget.matchDetails.clear();
        widget.matchDetails.addAll(fetchedDetails);
      });
    } catch (e) {
      print('Error fetching match details: $e');
    }
  }

  String _getFormattedDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getCountdown(DateTime startTime) {
    final now = DateTime.now();
    final difference = startTime.difference(now);

    if (difference.isNegative) {
      return "Live";
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;
      return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
    }
  }

  Widget _buildMatchList(String status) {
    final filteredMatches = widget.matchDetails
        .where((match) => match["status"] == status)
        .toList();

    return ListView.builder(
      itemCount: filteredMatches.length,
      itemBuilder: (context, index) {
        final match = filteredMatches[index];
        final startTime = match["startTime"] as DateTime?;
        final countdown =
            startTime != null ? _getCountdown(startTime) : "No start time set";
        final isCompleted = status == "Completed";
        final displayText =
            isCompleted ? "Completed" : (status == "Live" ? "Live" : countdown);
        final timeRemaining =
            startTime?.difference(DateTime.now()).inSeconds ?? 0;
        final lessThanOneMinute = timeRemaining > 0 && timeRemaining <= 60;

        return GestureDetector(
          onTap: () {
            if (status == "Live") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PointsTablePage(
                    tournamentName: match["tournamentName"],
                    tournamentId: match["tournamentId"],
                  ),
                ),
              );
            }
          },
          child: AnimatedScale(
            scale: 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                    color: Colors.white.withOpacity(0.8), width: 1.5),
              ),
              elevation: 10,
              shadowColor: Colors.cyanAccent.withOpacity(0.6),
              margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getFormattedDate(
                                      startTime ?? DateTime.now()),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromARGB(179, 255, 255, 255),
                                  ),
                                ),
                                Text(
                                  match["tournamentName"] ?? '',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD4AF37),
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                _deleteMatch(match["tournamentId"], index);
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                            ),
                            if (status != "Upcoming" && countdown != "Live")
                              ElevatedButton(
                                onPressed: () {
                                  _startMatch(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromRGBO(0, 122, 255, 1),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  "Start",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            if (status == "Live")
                              ElevatedButton(
                                onPressed: () {
                                  _endMatch(index);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  "End Match",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 500),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isCompleted
                                  ? Colors.greenAccent
                                  : (lessThanOneMinute
                                      ? Colors.redAccent
                                      : Colors.orangeAccent),
                            ),
                            child: Text(displayText),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Prize Pool",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.currency_rupee_rounded,
                                        color: Colors.grey),
                                    Text(
                                      " ${match["prizePool"]}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.tealAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Match Fee",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.currency_rupee,
                                        color: Colors.grey),
                                    Text(
                                      " ${match["matchFee"]}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.tealAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Players",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.group, color: Colors.grey),
                                    StreamBuilder<DocumentSnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('tournaments')
                                          .doc(match["tournamentId"])
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const Text(
                                            "Loading...",
                                            style: TextStyle(
                                                color: Colors.white70),
                                          );
                                        }

                                        if (!snapshot.hasData ||
                                            snapshot.data == null ||
                                            snapshot.data!.data() == null) {
                                          return const Text(
                                            "No data available",
                                            style: TextStyle(
                                                color: Colors.white70),
                                          );
                                        }
                                        final data = snapshot.data!.data()
                                            as Map<String, dynamic>;
                                        final joinedUsers = data["joinedUsers"]
                                                as List<dynamic>? ??
                                            [];
                                        final numPlayers =
                                            data["numPlayers"] ?? 0;

                                        return Text(
                                          "${joinedUsers.length} / $numPlayers",
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.tealAccent,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _startMatch(int index) {
    setState(() {
      widget.matchDetails[index]["status"] = "Live";
    });
  }

  Future<void> _deleteMatch(String tournamentId, int index) async {
    try {
      final tournamentDoc = await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(tournamentId)
          .get();

      if (tournamentDoc.exists) {
        final data = tournamentDoc.data();

        // Retrieve joinedUsers and numPlayers safely
        final List<dynamic> joinedUsers = data?['joinedUsers'] ?? [];
        final int numPlayers = data?['numPlayers'] ?? 0;
        final double matchFee = (data?['matchFee'] ?? 0).toDouble();

        if (joinedUsers.length != numPlayers) {
          // Update Account_Balance for each user in joinedUsers
          for (var userId in joinedUsers) {
            final userDoc =
                FirebaseFirestore.instance.collection('users').doc(userId);
            await FirebaseFirestore.instance
                .runTransaction((transaction) async {
              final snapshot = await transaction.get(userDoc);
              if (snapshot.exists) {
                final currentBalance =
                    snapshot.data()?['Account_Balance'] ?? 0.0;
                final updatedBalance = currentBalance + matchFee;

                transaction
                    .update(userDoc, {'Account_Balance': updatedBalance});
              }
            });
          }

          // Delete the tournament document after updating balances
          await FirebaseFirestore.instance
              .collection('tournaments')
              .doc(tournamentId)
              .delete();

          setState(() {
            widget.matchDetails.removeAt(index);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Tournament deleted successfully")),
          );
        } else {
          // Show error if the tournament is full
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cannot delete: Tournament is Full!")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tournament not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  void _endMatch(int index) async {
    final confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm End Tournament"),
          content: const Text(
              "Are you sure you want to mark this tournament as Completed?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("End"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final tournamentId = widget.matchDetails[index]["tournamentId"];

      setState(() {
        widget.matchDetails[index]["status"] = "Completed";
      });

      try {
        await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(tournamentId) // Use the match-specific ID
            .update({"status": "Completed"});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tournament marked as Completed")),
        );
      } catch (e) {
        print("Error updating tournament status: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    }
  }

  Future<void> _deleteCompletedTournaments() async {
    try {
      // Query Firestore for tournaments with "Completed" status
      final completedTournaments = await FirebaseFirestore.instance
          .collection('tournaments')
          .where("status", isEqualTo: "Completed")
          .get();

      // Delete each document
      for (var doc in completedTournaments.docs) {
        await doc.reference.delete();
      }

      // Update the local matchDetails list
      setState(() {
        widget.matchDetails
            .removeWhere((match) => match["status"] == "Completed");
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All Completed tournaments deleted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Match Details",
          style: GoogleFonts.breeSerif(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_sharp,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          if (_tabController.index == 2) // Show button only in Completed tab
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: "Delete All History",
              onPressed: _deleteCompletedTournaments,
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor: const Color.fromARGB(255, 182, 142, 9),
              labelColor: const Color.fromARGB(255, 182, 142, 9),
              unselectedLabelColor: Colors.white,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w900),
              onTap: (index) => setState(() {}), //change
              tabs: const [
                Tab(text: "Upcoming"),
                Tab(text: "Live"),
                Tab(text: "Completed"),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Color(0xFF101010)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchList("Upcoming"),
                  _buildMatchList("Live"),
                  _buildMatchList("Completed"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
