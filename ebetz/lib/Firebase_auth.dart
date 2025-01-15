// lib/auth_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login with email and password
  Future<User?> loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("Error logging in: $e");
      return null;
    }
  }

  Future<void> updateTeamPoints({
    required String tournamentId,
    required List<Map<String, dynamic>> teams,
  }) async {
    try {
      await _firestore.collection('tournaments').doc(tournamentId).update({
        'teams': teams,
      });
      print("Points updated successfully for tournament: $tournamentId");
    } catch (e) {
      print("Error updating points: $e");
    }
  }

  // Register with email, password, and unique username
  Future<User?> registerWithEmailAndPassword(
      String email, String password, String username,
      {bool isAdmin = false}) async {
    try {
      // Check if the username is unique
      final QuerySnapshot result = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (result.docs.isNotEmpty) {
        print("Username already exists. Choose a different username.");
        return null;
      }

      // Proceed with registration if username is unique
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      if (userCredential.user != null) {
        // Store user data in Firestore
        await _firestore.collection('users').doc(userCredential.user?.uid).set({
          'email': email,
          'username': username,
          'createdAt': FieldValue.serverTimestamp(),
          'isAdmin': isAdmin,          
          'matchesWin': 0,
          'Account_Balance': 0,
          'followers': 0,
          'following': 0,
          
        });

        print(
            "User registered successfully with UID: ${userCredential.user?.uid}");
      } else {
        print("Error: User registration failed.");
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException during registration: ${e.message}");
      return null;
    } catch (e) {
      print("Error during registration: $e");
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
