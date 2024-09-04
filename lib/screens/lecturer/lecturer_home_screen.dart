import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:qr_attemdance/screens/lecturer/create_class_session_page.dart';
import 'package:qr_attemdance/screens/lecturer/verify_student_indentity.dart';
import 'manage_attendance_page.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  _LecturerHomePageState createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CreateClassSessionPage(), // Lecturer creates a session here
    const ManageAttendancePage(),
    const VerifyStudentIdentityPage(sessionId: null), // Pass null for optional session ID
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the login page or show a message
      Navigator.pushReplacementNamed(context, '/login'); // Adjust the route as needed
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error signing out. Please try again.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _signOut, // Call the sign-out function
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner, size: 28),
            label: 'Create Session',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt, size: 28),
            label: 'Manage Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user, size: 28),
            label: 'Verify Identity',
          ),
        ],
      ),
    );
  }
}