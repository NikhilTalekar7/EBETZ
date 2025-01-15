import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // For formatting time

class UserFeedbackPage extends StatelessWidget {
  const UserFeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:Color.fromRGBO(1, 1, 1, 1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "User Feedback",
          style: GoogleFonts.breeSerif(
            fontSize: size.height * 0.03,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.black,
        child: SafeArea(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('user_feedback')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No feedback available",
                    style: GoogleFonts.breeSerif(
                      fontSize: size.height * 0.03,
                      color: Colors.white70,
                    ),
                  ),
                );
              }

              final feedbackDocs = snapshot.data!.docs;

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.02,
                ),
                itemCount: feedbackDocs.length,
                itemBuilder: (context, index) {
                  final feedback = feedbackDocs[index];
                  return Card(
                    color: Colors.white.withOpacity(0.1),
                    margin: EdgeInsets.only(bottom: size.height * 0.02),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black.withOpacity(0.3),
                    child: Padding(
                      padding: EdgeInsets.all(size.width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                "Rating: ${feedback['starRating'].toString()} ★",
                                style: GoogleFonts.cairo(
                                  fontSize: size.height * 0.022,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.4),
                            height: size.height * 0.03,
                          ),
                          Text(
                            "Feedback:",
                            style: GoogleFonts.cairo(
                              fontSize: size.height * 0.02,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            feedback['feedbackText'] ?? "No comments provided",
                            style: GoogleFonts.cairo(
                              fontSize: size.height * 0.02,
                              color: Colors.white,
                            ),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.4),
                            height: size.height * 0.03,
                          ),
                          Text(
                            "Answers:",
                            style: GoogleFonts.cairo(
                              fontSize: size.height * 0.02,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: size.height * 0.01),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: feedback['answers'].entries.map<Widget>((entry) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: size.height * 0.015),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.key,
                                      style: GoogleFonts.cairo(
                                        fontSize: size.height * 0.02,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.005),
                                    Text(
                                      entry.value,
                                      style: GoogleFonts.cairo(
                                        fontSize: size.height * 0.02,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Divider(
                            color: Colors.white.withOpacity(0.4),
                            height: size.height * 0.03,
                          ),
                          Row(
                            children: [
                              const Icon(Icons.access_time, color: Colors.white70),
                              const SizedBox(width: 8),
                              Text(
                                "Submitted at: ${feedback['timestamp'] != null ? DateFormat('dd MMM yyyy, HH:mm').format((feedback['timestamp'] as Timestamp).toDate()) : "Unknown"}",
                                style: GoogleFonts.cairo(
                                  fontSize: size.height * 0.018,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70,
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
          ),
        ),
      ),
    );
  }
}