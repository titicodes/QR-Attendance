import 'package:flutter/material.dart';
import 'package:qr_attemdance/screens/lecturer/attendance_list_pge.dart';
import 'package:qr_attemdance/screens/lecturer/verify_student_indentity.dart';
import 'create_class_session_page.dart';
import 'manage_attendance_page.dart';

class LecturerHomePage extends StatefulWidget {
  const LecturerHomePage({super.key});

  @override
  _LecturerHomePageState createState() => _LecturerHomePageState();
}

class _LecturerHomePageState extends State<LecturerHomePage> {
  String? sessionId; // Store sessionId here
  int _selectedIndex = 0;

  List<Widget> _pages() => [
        CreateClassSessionPage(
          onSessionCreated: (String createdSessionId) {
            setState(() {
              sessionId = createdSessionId;
            });
          },
        ),
        const ManageAttendancePage(),
        const VerifyStudentIdentityPage(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lecturer Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      body: _pages()[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Create Session',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Manage Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check),
            label: 'Verify Identity',
          ),
        ],
      ),
    );
  }
}
