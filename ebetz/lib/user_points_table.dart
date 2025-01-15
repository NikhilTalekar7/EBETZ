// import 'dart:developer';

// import 'package:ebetz/show_tournament_result.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class PointsTableDisplay extends StatelessWidget {
//   final String tournamentName;
//   final String
//       tournamentId; // Added tournamentId for passing to TournamentResultsPage

//   const PointsTableDisplay({
//     super.key,
//     required this.tournamentName,
//     required this.tournamentId,
//   });

//   Stream<List<Map<String, dynamic>>> _fetchPointsTable() {
//     return FirebaseFirestore.instance
//         .collection('points_table')
//         .where('tournamentName', isEqualTo: tournamentName)
//         .snapshots()
//         .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "$tournamentName - Points Table",
//           style: const TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: StreamBuilder<List<Map<String, dynamic>>>(
//               stream: _fetchPointsTable(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(
//                     child: Text(
//                       "No points data available.",
//                       style: TextStyle(color: Colors.grey, fontSize: 18),
//                     ),
//                   );
//                 }

//                 final pointsTable = snapshot.data!;
//                 return ListView.builder(
//                   padding: const EdgeInsets.all(16.0),
//                   itemCount: pointsTable.length,
//                   itemBuilder: (context, index) {
//                     final entry = pointsTable[index];
//                     return Card(
//                       color: Colors.black87,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12.0),
//                         side: const BorderSide(color: Colors.white, width: 1.5),
//                       ),
//                       child: ListTile(
//                         title: Text(
//                           entry['teamName'] ?? 'Unknown Team',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         trailing: Text(
//                           "${entry['points']} pts",
//                           style: const TextStyle(
//                             color: Colors.tealAccent,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               onPressed: () {
//                 log(tournamentName);
//                 log(tournamentId);
//                 // Future<void> updateTotalPoints() async {
//                 //   try {
//                 //     final firestore = FirebaseFirestore.instance;

//                 //     // Fetch the document for the current user
//                 //     final docRef = firestore
//                 //         .collection("super_teams")
//                 //         .doc(widget.username);
//                 //     final docSnapshot = await docRef.get();

//                 //     if (!docSnapshot.exists) {
//                 //       ScaffoldMessenger.of(context).showSnackBar(
//                 //         const SnackBar(
//                 //             content:
//                 //                 Text("No team selection found to update.")),
//                 //       );
//                 //       return;
//                 //     }

//                 //     // Retrieve the selected teams and super team
//                 //     final data = docSnapshot.data();
//                 //     final selectedTeams =
//                 //         List<String>.from(data!['selectedTeams']);
//                 //     final superTeamName = data['superTeam'] as String?;
//                 //     int totalPoints = 0;

//                 //     // Calculate total points from points_table
//                 //     for (var teamName in selectedTeams) {
//                 //       final querySnapshot = await firestore
//                 //           .collection('points_table')
//                 //           .where('tournamentId',
//                 //               isEqualTo: data['tournamentId'])
//                 //           .where('teamName', isEqualTo: teamName)
//                 //           .where('tournamentName',
//                 //               isEqualTo: data['tournamentName'])
//                 //           .get();

//                 //       if (querySnapshot.docs.isNotEmpty) {
//                 //         final teamPoints =
//                 //             querySnapshot.docs.first['points'] as int;

//                 //         // Add points, with a bonus for the super team
//                 //         if (teamName == superTeamName) {
//                 //           totalPoints += teamPoints * 2;
//                 //         } else {
//                 //           totalPoints += teamPoints;
//                 //         }
//                 //       }
//                 //     }

//                 //     // Update totalPoints in Firestore
//                 //     await docRef.update({"totalPoints": totalPoints});

//                 //     ScaffoldMessenger.of(context).showSnackBar(
//                 //       const SnackBar(
//                 //           content: Text("Points updated successfully!")),
//                 //     );
//                 //   } catch (e) {
//                 //     ScaffoldMessenger.of(context).showSnackBar(
//                 //       SnackBar(content: Text("Failed to update points: $e")),
//                 //     );
//                 //   }
//                 // }

//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => TournamentResultsPage(
//                       tournamentName: tournamentName,
//                       tournamentId: tournamentId, // Pass tournamentId
//                     ),
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blueAccent,
//               ),
//               child: const Text("Show Results"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // TournamentResultsPage should be imported or defined elsewhere
// // class TournamentResultsPage extends StatelessWidget {
// //   final String tournamentName;
// //   final String tournamentId;

// //   const TournamentResultsPage({
// //     super.key,
// //     required this.tournamentName,
// //     required this.tournamentId,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text("$tournamentName Results"),
// //         backgroundColor: Colors.black,
// //       ),
// //       body: Center(
// //         child: Text(
// //           "Tournament Results Page for $tournamentName",
// //           style: const TextStyle(fontSize: 18, color: Colors.white),
// //         ),
// //       ),
// //     );
// //   }
// // }

import 'dart:developer';
import 'package:ebetz/show_tournament_result.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class PointsTableDisplay extends StatelessWidget {
  final String tournamentName;
  final String tournamentId;

  PointsTableDisplay({
    super.key,
    required this.tournamentName,
    required this.tournamentId,
  });

  Stream<List<Map<String, dynamic>>> _fetchPointsTable() {
    return FirebaseFirestore.instance
        .collection('points_table')
        .where('tournamentName', isEqualTo: tournamentName)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

   final List<Map<String, dynamic>> teams = [
    {"name": "t1", "credit": 10.0, "image": "assets/images/logo1.jpg"},
    {"name": "t2", "credit": 10.0, "image": "assets/images/logo2.jpg"},
    {"name": "t3", "credit": 10.0, "image": "assets/images/logo3.jpg"},
    {"name": "t4", "credit": 10.0, "image": "assets/images/logo4.jpg"},
    {"name": "t5", "credit": 20.0, "image": "assets/images/logo5.jpg"},
    {"name": "t6", "credit": 20.0, "image": "assets/images/logo6.jpg"},
    {"name": "t7", "credit": 20.0, "image": "assets/images/logo7.jpg"},
    {"name": "t8", "credit": 20.0, "image": "assets/images/logo8.jpg"},
    {"name": "t9", "credit": 30.0, "image": "assets/images/logo9.jpg"},
    {"name": "t10", "credit": 30.0, "image": "assets/images/logo1.jpg"},
    {"name": "t11", "credit": 30.0, "image": "assets/images/logo3.jpg"},
    {"name": "t12", "credit": 30.0, "image": "assets/images/logo1.jpg"},
    {"name": "t13", "credit": 40.0, "image": "assets/images/logo6.jpg"},
    {"name": "t14", "credit": 40.0, "image": "assets/images/logo8.jpg"},
    {"name": "t15", "credit": 40.0, "image": "assets/images/logo4.jpg"},
    {"name": "t16", "credit": 40.0, "image": "assets/images/logo2.jpg"},
  ];

@override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 0, 41, 1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "$tournamentName - Points Table",
          style: GoogleFonts.breeSerif(
            fontWeight: FontWeight.w700,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
          Navigator.pop(context);
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
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _fetchPointsTable(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "No points data available.",
                      style: TextStyle(color: Colors.white70, fontSize: 18),
                    ),
                  );
                }

                final pointsTable = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: pointsTable.length,
                  itemBuilder: (context, index) {
                    final entry = pointsTable[index];
                    final teamImage = teams[index]['image'];
                    return Card(
                      color: const Color.fromRGBO(255, 255, 255, 0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 255, 255, 255),
                          width: 1.5,
                        ),
                      ),
                      elevation: 8.0,
                      shadowColor: Colors.black.withOpacity(0.3),
                      child: ListTile(
                          leading: teamImage != null
                              ? CircleAvatar(
                                  backgroundImage: AssetImage(teamImage),
                                  backgroundColor: Colors.transparent,
                                )
                              : const CircleAvatar(
                                  backgroundColor:
                                      Color.fromRGBO(53, 152, 219, 1),
                                  child: Icon(Icons.group, color: Colors.white),
                                ),
                        title: Text(
                          entry['teamName'] ?? 'Unknown Team',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Text(
                          "${entry['points']} pts",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16,left: 16,right: 16,bottom: 30),
            child: ElevatedButton(
             onPressed: () async {
              log(tournamentId);
              log(tournamentName);
                try {
                  final firestore = FirebaseFirestore.instance;

                  // Fetch the tournament document by tournamentName
                  final querySnapshot = await firestore
                      .collection('tournaments')
                      .where('tournamentName', isEqualTo: tournamentName)
                      .get();

                  if (querySnapshot.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tournament not found.")),
                    );
                    return;
                  }

                  final tournamentDoc = querySnapshot.docs.first;
                  final tournamentData = tournamentDoc.data();

                  // Extract matchFee, numPlayers, and prizePool
                  final matchFee = tournamentData['matchFee'] as int? ?? 0;
                  final numPlayers = tournamentData['numPlayers'] as int? ?? 0;
                  final prizePool = tournamentData['prizePool'] as int? ?? 0;

                  // Calculate revenue
                  final revenue = (matchFee * numPlayers) - prizePool;

                  // Update the revenue field in the tournament document
                  await tournamentDoc.reference.update({'revenue': revenue});

                

                  // Navigate to the TournamentResultsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TournamentResultsPage(
                        tournamentName: tournamentName,
                        tournamentId: tournamentDoc.id, // Pass the tournamentId
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Failed to update revenue: $e")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.12, vertical: screenHeight * 0.02),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                backgroundColor: Color.fromRGBO(0, 122, 255, 1),
                elevation: 6.0,
                shadowColor: Colors.tealAccent.withOpacity(0.4),
              ),
              child:  Text(
                "Show Results",
                style:GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}




