import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final TextEditingController feedbackController = TextEditingController();
  double starRating = 0;
  final List<String> questions = [
    "How is the app's performance?",
    "Is the UI user-friendly?",
    "Would you recommend this app to others?",
  ];
  final Map<String, String> selectedAnswers = {};

  // A method to check if all fields are filled
  bool _validateFields() {
    if (feedbackController.text.isEmpty) {
      return false; // Feedback text is required
    }
    if (starRating == 0) {
      return false; // Star rating is required
    }
    if (selectedAnswers.length < questions.length) {
      return false; // All questions must have answers
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
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
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_sharp,
                        color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(width: size.width * 0.2),
                  Text(
                    "Feedback",
                    style: GoogleFonts.breeSerif(
                      fontSize: size.height * 0.03,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: size.width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "We value your feedback!",
                            style: GoogleFonts.breeSerif(
                              fontSize: size.height * 0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Rate your experience:",
                          style: GoogleFonts.cairo(
                            fontSize: size.height * 0.022,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (index) {
                              return IconButton(
                                icon: Icon(
                                  index < starRating
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: const Color.fromARGB(255, 182, 142, 9),
                                  size: size.height * 0.04,
                                ),
                                onPressed: () {
                                  setState(() {
                                    if (starRating == (index + 1).toDouble()) {
                                      starRating = index
                                          .toDouble(); // Revert to previous state
                                    } else {
                                      starRating = (index + 1)
                                          .toDouble(); // Set to the clicked star
                                    }
                                  });
                                },
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Answer the following questions:",
                          style: GoogleFonts.cairo(
                            fontSize: size.height * 0.022,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...questions.asMap().entries.map((entry) {
                          final question = entry.value;
                          final index = entry.key;
                          final List<DropdownMenuItem<String>> items =
                              index == 0
                                  ? const [
                                      DropdownMenuItem(
                                        value: "Excellent",
                                        child: Text("Excellent"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Good",
                                        child: Text("Good"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Average",
                                        child: Text("Average"),
                                      ),
                                      DropdownMenuItem(
                                        value: "Poor",
                                        child: Text("Poor"),
                                      ),
                                    ]
                                  : const [
                                      DropdownMenuItem(
                                          value: "Yes", child: Text("Yes")),
                                      DropdownMenuItem(
                                          value: "No", child: Text("No")),
                                    ];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  question,
                                  style: GoogleFonts.cairo(
                                    fontSize: size.height * 0.02,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: double.infinity, // Reduced size for responsiveness
                                  child: DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.white70),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                            color: Colors.blueAccent, width: 2),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 16,
                                      ),
                                    ),
                                    dropdownColor:
                                        const Color.fromRGBO(53, 52, 92, 1),
                                    icon: const Icon(Icons.expand_more,
                                        color: Colors.white, size: 24),
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: size.height * 0.02,
                                    ),
                                    items: items,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedAnswers[question] = value!;
                                      });
                                    },
                                    value: selectedAnswers[question],
                                    hint: Row(
                                      children: [
                                        const Icon(Icons.menu,
                                            color: Colors.white70, size: 18),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Select",
                                          style: GoogleFonts.cairo(
                                            color: Colors.white70,
                                            fontSize: size.height * 0.018,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 20),
                        Text(
                          "Additional Comments:",
                          style: GoogleFonts.cairo(
                            fontSize: size.height * 0.022,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: TextField(
                            controller: feedbackController,
                            maxLines: 5,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Share your thoughts here...",
                              hintStyle:
                                  GoogleFonts.cairo(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 0, 77, 158),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: size.width * 0.1,
                                vertical: size.height * 0.02,
                              ),
                            ),
                            onPressed: () async {
                              if (_validateFields()) {
                                try {
                                  // Prepare the feedback data
                                  final feedbackData = {
                                    "starRating": starRating,
                                    "feedbackText": feedbackController.text,
                                    "answers": selectedAnswers,
                                    "timestamp": FieldValue.serverTimestamp(),
                                  };

                                  // Store the feedback in Firestore
                                  await FirebaseFirestore.instance
                                      .collection("user_feedback")
                                      .add(feedbackData);

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text("Thank you for your feedback!"),
                                    ),
                                  );

                                  // Clear fields after submission
                                  feedbackController.clear();
                                  setState(() {
                                    starRating = 0;
                                    selectedAnswers.clear();
                                  });
                                } catch (e) {
                                  // Handle Firestore errors
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Failed to submit feedback: $e"),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Please provide all required feedback before submitting.",
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text(
                              "Submit Feedback",
                              style: GoogleFonts.breeSerif(
                                  fontSize: size.height * 0.022,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}