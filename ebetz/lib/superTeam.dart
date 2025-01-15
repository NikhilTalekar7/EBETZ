import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

import 'betsuccess.dart';

class SuperTeamSelection extends StatefulWidget {
  final List<Map<String, dynamic>> selectedTeams;
  final String username;
  final String gameName;
  final String tournamentId; // Pass username as a parameter
  final String tournamentName;

  const SuperTeamSelection(
      {super.key,
      required this.selectedTeams,
      required this.username,
      required this.gameName,
      required this.tournamentId,
      required this.tournamentName});

  @override
  State createState() => _SuperTeamSelectionState();
}

class _SuperTeamSelectionState extends State<SuperTeamSelection> {
  String? superTeam; // Store only the name of the Super Team

  void selectSuperTeam(Map<String, dynamic> team) {
    setState(() {
      superTeam = team['name'];
    });
  }

  Future<void> saveToFirestore() async {
    try {
      final firestore = FirebaseFirestore.instance;

      // Fetch points for all selected teams
      int totalPoints = 0;
      for (var team in widget.selectedTeams) {
        final teamName = team['name'];
        final querySnapshot = await firestore
            .collection('points_table')
            .where('tournamentId', isEqualTo: widget.tournamentId)
            .where('teamName', isEqualTo: teamName)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          final teamPoints = querySnapshot.docs.first['points'] as int;
          totalPoints += teamPoints;

          // Add bonus for the super team (2x points)
          if (teamName == superTeam) {
            totalPoints +=
                teamPoints; // Add an extra set of points for the bonus
          }
        }
      }

      // Create a map of data to save
      final data = {
        "username": widget.username,
        "gameName": widget.gameName,
        "tournamentId": widget.tournamentId,
        "tournamentName": widget.tournamentName,
        "selectedTeams":
            widget.selectedTeams.map((team) => team['name']).toList(),
        "superTeam": superTeam,
        "totalPoints": 0,
      };

      // Save to Firestore (use the username as the document ID)
      await firestore.collection("super_teams").doc(widget.username).set(data);


      //navigate to betsuccessScreen//
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BetsuccessScreen(),
        ),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(0, 0, 41, 1),
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Select Super Team",
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
        padding: EdgeInsets.all(screenWidth * 0.04),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Select one team as your Super Team",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: screenWidth * 0.048,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                 ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.selectedTeams.length,
                      itemBuilder: (context, index) {
                        final team = widget.selectedTeams[index];
                        final teamName = team["name"];
                        final isSelected = superTeam == teamName;

                        return GestureDetector(
                          onTap: () => selectSuperTeam(team),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                                vertical: screenHeight * 0.01),
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Colors.greenAccent,
                                        Colors.blueAccent,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [
                                        Colors.grey[800]!,
                                        const Color.fromRGBO(53, 52, 92, 1),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                  color: isSelected
                                      ? Colors.greenAccent.withOpacity(0.5)
                                      : Colors.black.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: screenWidth * 0.08,
                                  backgroundColor: Colors.grey.shade800,
                                  backgroundImage:  AssetImage(
                                    team['image']),
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Expanded(
                                  child: Text(
                                    teamName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                  ),
                                ),
                                if (isSelected) ...[
                                  const Icon(Icons.check_circle,
                                      color: Colors.white, size: 28),
                                  const SizedBox(width: 8),
                                  AnimatedScale(
                                    scale: 1,
                                    duration: const Duration(milliseconds: 300),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        "2x",
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Note: The Super Team will gain 2x points!",
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: superTeam != null ? saveToFirestore : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 0, 77, 158),
                        disabledBackgroundColor:
                            const Color.fromARGB(255, 0, 77, 158),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                          vertical: screenHeight * 0.02,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 6,
                        shadowColor: Color.fromRGBO(20, 20, 32, 1),
                      ),
                      child: Text(
                        "Confirm Selection",
                        style: GoogleFonts.cairo(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
