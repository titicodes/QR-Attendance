import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_attemdance/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign up with email and password
  Future<AppUser?> signUp(
    String email,
    String password,
    String role,
    String fullName,
    String phoneNumber,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      // Store user information in Firestore
      await _db.collection('users').doc(user?.uid).set({
        'role': role,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
      });
      
      return AppUser(
        uid: user!.uid,
        role: role,
        fullName: fullName,
        phoneNumber: phoneNumber,
      );
    } catch (e) {
      print('Error during sign up: $e');
      return null;
    }
  }

  // Sign in with email and password
  Future<AppUser?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      
      // Retrieve user data from Firestore
      DocumentSnapshot doc = await _db.collection('users').doc(user?.uid).get();
      
      if (doc.exists) {
        String role = doc.get('role');
        String fullName = doc.get('fullName');
        String phoneNumber = doc.get('phoneNumber');
        
        return AppUser(
          uid: user!.uid,
          role: role,
          fullName: fullName,
          phoneNumber: phoneNumber,
        );
      } else {
        print('User document does not exist in Firestore.');
        return null;
      }
    } catch (e) {
      print('Error during sign in: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

    Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Handle errors here, e.g., log them or show a message
      print('Error resetting password: $e');
      throw e; // Optionally, rethrow the error for higher-level handling
    }
  }
}
