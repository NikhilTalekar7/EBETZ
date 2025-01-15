import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home.dart';
import 'navigation.dart';

class BetsuccessScreen extends StatelessWidget {
  const BetsuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 40, 40, 70),
              Color.fromARGB(255, 20, 20, 30),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            // Top Confetti Effect
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Icon(
                  Icons.celebration,
                  size: 150,
                  color: Colors.green.withOpacity(0.3),
                ),
              ),
            ),
            // Center Content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Checkmark
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                     
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.1),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset('assets/images/betsucess.gif')
                  ),
                  const SizedBox(height: 20),
                  // Success Message
                   Text(
                    'Bet Joined Successfully',
                    style: GoogleFonts.breeSerif(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  // Fancy Button
                  ElevatedButton(
                    onPressed: () {   

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Join successfully',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );                   
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => NavigatorScreen(0)),
                        (route) =>false, // Predicate to remove routes (return false to clear all)
                      );              
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 32, 128, 35),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      shadowColor: Color.fromARGB(255, 80, 137, 88),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}

