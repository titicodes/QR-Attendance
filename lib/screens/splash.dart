import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_attemdance/screens/lecturer/lecturer_home_screen.dart';
import 'package:qr_attemdance/screens/students/student_home_screen.dart';
import 'admin/dmin_home.dart';
import 'login_screen.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasData && snapshot.data != null) {
          User? user = snapshot.data;
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(user!.uid)
                .get(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              } else if (roleSnapshot.hasData && roleSnapshot.data != null) {
                if (!roleSnapshot.data!.exists) {
                  // If the document does not exist, navigate to the login screen
                  return const LoginPage();
                }

                final roleData = roleSnapshot.data!.data() as Map<String, dynamic>?;

                if (roleData != null && roleData.containsKey('role')) {
                  final role = roleData['role'];
                  if (role == 'admin') {
                    return const AdminHomePage();
                  } else if (role == 'lecturer') {
                    return const LecturerHomePage();
                  } else if (role == 'student') {
                    return const StudentHomePage(regNumber: '',);
                  } else {
                    return const LoginPage(); // Unknown role
                  }
                } else {
                  return const LoginPage(); // Handle missing role field
                }
              } else {
                return const LoginPage(); // Handle snapshot error or missing document
              }
            },
          );
        } else {
          return const LoginPage(); // User is not signed in
        }
      },
    );
  }
}
