import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceListPage extends StatelessWidget {
  final String sessionId;

  const AttendanceListPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    // Check if sessionId is empty and show a message to create a session first
    if (sessionId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Attendance List')),
        body: const Center(
          child: Text('Please create a session first.'),
        ),
      );
    }

    // Proceed to query Firestore if sessionId is valid
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('class_sessions')
            .doc(sessionId)
            .collection('attendances')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(child: Text('No students found.'));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              var student = students[index];
              return ListTile(
                title: Text('Reg Number: ${student['regNumber']}'),
                subtitle: Text('Status: ${student['attendanceStatus']}'),
              );
            },
          );
        },
      ),
    );
  }
}
