import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:qr_attemdance/screens/lecturer/attendnce_detil_page.dart';

class ManageAttendancePage extends StatelessWidget {
  const ManageAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Attendance'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('sessions').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading sessions.'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No sessions available.'));
            }

            var sessions = snapshot.data!.docs;

            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                var session = sessions[index];

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.class_, color: Colors.white),
                    ),
                    title: Text(
                      session['courseTitle'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Course Code: ${session['courseCode']}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Date: ${formatDate(session['classDate'])}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.visibility, color: Colors.blueAccent),
                      onPressed: () {
                        // Navigate to attendance details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AttendanceDetailsPage(sessionId: session.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String formatDate(Timestamp timestamp) {
    var date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
  }
}