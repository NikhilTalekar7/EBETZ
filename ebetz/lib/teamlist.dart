import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'superTeam.dart';

class TeamListPage extends StatefulWidget {
  final String tournamentId;
  final String gameName;
  final String tournamentName;

  const TeamListPage({
    required this.tournamentId,
    required this.gameName,
    required this.tournamentName,
    super.key,
  });

  @override
  State createState() => _TeamListPageState();
}

class _TeamListPageState extends State<TeamListPage> {
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
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        final userDoc = await firestore.collection('users').doc(userId).get();
        setState(() {
          username = userDoc.data()?['username'] ?? 'Unknown User';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fetch username.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  final List<Map<String, dynamic>> selectedTeams = [];
  double playerCredit = 100; // Initial player credit
  String? username;

  void toggleTeamSelection(Map<String, dynamic> team) {
    setState(() {
      if (selectedTeams.contains(team)) {
        selectedTeams.remove(team);
        playerCredit += team['credit']; // Refund credits
      } else {
        if (selectedTeams.length < 4) {
          if (playerCredit >= team['credit']) {
            selectedTeams.add(team);
            playerCredit -= team['credit']; // Deduct credits
          } else {
            // Show Snackbar when credit is insufficient
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Not enough credits to select ${team['name']}!',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    });
  }

  Future<void> saveSelectedTeams(BuildContext context) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to save your team.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Save selected teams to Firestore
      await firestore.collection('users').doc(userId).update({
        'selectedTeams': {
          'tournamentId': widget.tournamentId,
          'teams': selectedTeams.map((team) => team['name']).toList(),
          'totalCreditsUsed': 100 - playerCredit, // Total credits spent
        },
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teams saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save teams.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
           leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_sharp, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromRGBO(0, 0, 41, 1),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
             Text("Team Selection",style: GoogleFonts.breeSerif(color: Colors.white),),
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet,
                      color: Color.fromARGB(255, 255, 163, 59)),
                  const SizedBox(width: 8),
                  Text(
                    playerCredit.toStringAsFixed(1),
                    style: GoogleFonts.breeSerif(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
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
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
            ),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              final isSelected = selectedTeams.contains(team);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 80, 200, 120),
                            Color.fromARGB(255, 25, 130, 200),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      :  LinearGradient(
                          colors: [
                            Colors.grey[800]!,const Color.fromRGBO(53, 52, 92, 1)
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? Colors.greenAccent.withOpacity(0.5)
                          : Colors.black.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 8,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => toggleTeamSelection(team),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: AssetImage(team["image"]),
                        backgroundColor: Colors.transparent,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        team["name"],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Credits: ${team["credit"]}",
                        textAlign: TextAlign.center,
                        style:GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color:  Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (selectedTeams.length == 4) {
              await saveSelectedTeams(context);
              if (username != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SuperTeamSelection(
                      selectedTeams: selectedTeams,
                      username: username!,
                      gameName: widget.gameName,
                      tournamentId: widget.tournamentId,
                      tournamentName: widget.tournamentName,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to load username.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select exactly 4 teams!'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          backgroundColor: Color.fromRGBO(34, 33, 62, 1),
          child: const Icon(Icons.arrow_forward, size: 30,color: Colors.white,),
        ));
  }
}
