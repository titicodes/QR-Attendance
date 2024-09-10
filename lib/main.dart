import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:qr_attemdance/firebase_options.dart';
import 'package:qr_attemdance/screens/admin/dmin_home.dart';
import 'package:qr_attemdance/screens/lecturer/scan_student_id.dart';
import 'package:qr_attemdance/screens/lecturer/verify_student_indentity.dart';
import 'package:qr_attemdance/screens/login_screen.dart';
import 'package:qr_attemdance/screens/signup_screen.dart';
import 'package:qr_attemdance/screens/splash.dart';
import 'screens/lecturer/lecturer_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          titleLarge: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.black54),
        ),
        buttonTheme: ButtonThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          buttonColor: Colors.blueAccent,
          textTheme: ButtonTextTheme.primary,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.orangeAccent),
      ),
      home: const AuthChecker(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/adminHome': (context) => const AdminHomePage(),
        '/lecturerHome': (context) => const LecturerHomePage(),
        // '/manageAttendance': (context) => const ManageAttendancePage(
        //     sessionId: ''), // Pass sessionId dynamically in LecturerHomePage
        '/scanStudentID': (context) => const ScanStudentIDPage(
            sessionId: ''), // Also pass sessionId dynamically
        '/verifyStudentIdentity': (context) =>
            const VerifyStudentIdentityPage(),
        '/error': (context) => const ErrorPage(),
      },
    );
  }
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: const Center(child: Text('An error occurred. Please try again.')),
    );
  }
}
