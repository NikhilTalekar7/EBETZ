import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ebetz/user_points_table.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class UserMyMatches extends StatelessWidget {
  const UserMyMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyBetsPage(),
    );
  }
}

class MyBetsPage extends StatelessWidget {
  const MyBetsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Container(
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
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(0, 0, 41, 1),
            elevation: 0,
            title: Text(
              'My Bets',
              style: GoogleFonts.breeSerif(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            bottom: TabBar(
              indicatorColor: const Color.fromARGB(255, 182, 142, 9),
              labelColor: const Color.fromARGB(255, 182, 142, 9),
              unselectedLabelColor: Colors.white,
              labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w900),
              unselectedLabelStyle: GoogleFonts.cairo(),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Live'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          body: const TabBarView(
            children: [
              TournamentSection(status: 'Upcoming'),
              TournamentSection(status: 'Live'),
              TournamentSection(status: 'Completed'),
            ],
          ),
        ),
      ),
    );
  }
}

class TournamentSection extends StatelessWidget {
  final String status;

  const TournamentSection({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    // ignore: unused_element
    Future<void> _deleteCompletedTournaments(
        BuildContext context, String userId) async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete History'),
          content: const Text(
            'Are you sure you want to delete all completed tournaments? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        try {
          final snapshots = await FirebaseFirestore.instance
              .collection('tournaments')
              .where('status', isEqualTo: 'Completed')
              .where('joinedUsers', arrayContains: userId)
              .get();

          for (final doc in snapshots.docs) {
            await doc.reference.delete();
          }

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Completed history deleted successfully.'),
            ),
          );
        } catch (error) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete history: $error'),
            ),
          );
        }
      }
    }

    if (userId == null) {
      return const Center(
        child: Text(
          'Please log in to view your bets.',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return
      
    // StreamBuilder for displaying tournaments
    Expanded(
        child: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tournaments')
          .where('status', isEqualTo: status)
          .where('joinedUsers', arrayContains: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }
    
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading $status matches.',
              style: const TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
    
        final tournaments = snapshot.data?.docs ?? [];
        if (tournaments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sentiment_dissatisfied,
                    color: Colors.grey[400], size: 80),
                const SizedBox(height: 16),
                Text(
                  'No bets in $status.',
                  style: GoogleFonts.cairo(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }
    
        return LayoutBuilder(
          builder: (context, constraints) {
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final data =
                    tournaments[index].data() as Map<String, dynamic>;
    
                final dynamic rawStartTime = data['startTime'];
                DateTime startTime;
                if (rawStartTime is Timestamp) {
                  startTime = rawStartTime.toDate();
                } else if (rawStartTime is String) {
                  startTime = _parseDateString(rawStartTime);
                } else {
                  startTime = DateTime.now();
                }
                final tournamentName =
                    data['tournamentName'] ?? 'Unknown Tournament';
                // final tournamentId =
                //     data['tournamentId'] ?? 'Unknown Tournament';
    
                return GestureDetector(
                  onTap: status == 'Completed'
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PointsTableDisplay(
                                tournamentName: tournamentName,
                                tournamentId: '',
                              ),
                            ),
                          );
                        }
                      : null,
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Card(
                      color: Colors.transparent,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      elevation: 5,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A2D37), Color(0xFF121212)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          border:
                              Border.all(color: Colors.white70, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10.0,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${data['gameName']} - $tournamentName',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (status == 'Upcoming') ...[
                                Center(
                                  child: CountdownTimer(
                                    startTime: startTime,
                                    tournamentId: tournaments[index].id,
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                              const SizedBox(height: 12),
                              if (status == 'Live' || status == 'Completed')
                                Text(
                                  status == 'Live' ? 'Live' : 'Completed',
                                  style: TextStyle(
                                    fontSize: constraints.maxWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: status == 'Live'
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const FaIcon(FontAwesomeIcons.moneyBill,
                                          color: Colors.tealAccent, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Entry Fee: ₹${data['matchFee']}',
                                        style: TextStyle(
                                          fontSize:
                                              constraints.maxWidth * 0.04,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const FaIcon(FontAwesomeIcons.trophy,
                                          color: Colors.orangeAccent,
                                          size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Prize Pool: ₹${data['prizePool']}',
                                        style: TextStyle(
                                          fontSize:
                                              constraints.maxWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    ));
  }

  DateTime _parseDateString(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
}

class CountdownTimer extends StatefulWidget {
  final DateTime startTime;
  final String tournamentId;

  const CountdownTimer({
    super.key,
    required this.startTime,
    required this.tournamentId,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CountdownTimerState createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration remainingTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    remainingTime = widget.startTime.difference(DateTime.now());

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          remainingTime = widget.startTime.difference(DateTime.now());
        });
      }
      if (remainingTime.isNegative) {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = remainingTime.inHours;
    final minutes = remainingTime.inMinutes.remainder(60);
    final seconds = remainingTime.inSeconds.remainder(60);

    return Text(
      remainingTime.isNegative
          ? 'Match Started'
          : '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      style: GoogleFonts.cairo(
        fontSize: 18,
        color: Colors.orangeAccent,
      ),
    );
  }
}