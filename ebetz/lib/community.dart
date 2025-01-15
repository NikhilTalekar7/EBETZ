import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button and Title
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new_sharp),
                        color: Colors.white,
                      ),
                       SizedBox(width: 0.25*screenWidth),
                      Text(
                        "Policy",
                        style: GoogleFonts.breeSerif(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Sections
                  _buildSectionCard(
                    context,
                    title: "1. Introduction",
                    content:
                        "This Legal Policy outlines the terms and conditions for using EBETZ. By registering for and using this App, you agree to comply with all applicable laws and regulations. If you do not agree with any part of this policy, discontinue the use of the App immediately.",
                  ),
                  _buildSectionCard(
                    context,
                    title: "2. User Eligibility",
                    content:
                        "- Age Restriction**: Users must be at least [minimum legal gambling age in the jurisdiction] years old.\n"
                        "- Jurisdictional Restrictions**: The App is not available in jurisdictions where online betting is prohibited.\n"
                        "- Account Verification**: Users are required to verify their identity through a government-issued ID and proof of address.",
                  ),
                  _buildSectionCard(
                    context,
                    title: "3. Responsible Gambling",
                    content:
                        "- Self-Exclusion**: Tools for self-exclusion and account limits are available to prevent problem gambling.\n"
                        "- Support Resources**: Access to resources such as helplines and counseling services for gambling addiction.\n"
                        "- Risk Disclosure**: Betting involves financial risk. Users must wager responsibly and at their own risk.",
                  ),
                  _buildSectionCard(
                    context,
                    title: "4. Privacy Policy",
                    content:
                        "- Data Collection**: The App collects personal data for account verification and operational purposes.\n"
                        "- Data Protection**: All user data is protected in compliance with [applicable data protection laws, e.g., GDPR, CCPA].\n"
                        "- Third-Party Sharing**: User data will not be shared with third parties without consent, except as required by law.",
                  ),
                  const SizedBox(height: 30),
                  // Contact Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "For any questions or concerns, contact us at:",
                            style: GoogleFonts.breeSerif(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "- Email: ebetz@gmail.com\n"
                          "- Phone: 475216xx78",
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Section Card Widget
  Widget _buildSectionCard(BuildContext context,
      {required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color:Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
