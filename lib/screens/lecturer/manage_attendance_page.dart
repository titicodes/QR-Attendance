import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'attendnce_detil_page.dart'; // Assuming you have this page for attendance details

class ManageAttendancePage extends StatelessWidget {
  const ManageAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('class_sessions')
              .snapshots(),
          builder: (context, snapshot) {
            // If still loading data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // If there's an error in the snapshot
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // If no data available or empty collection
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No class sessions available.'));
            }

            // If data is available, proceed to display the sessions
            var sessions = snapshot.data!.docs;

            return ListView.builder(
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                var session = sessions[index];

                // Check if the necessary fields exist in the document
                if (session['courseTitle'] == null ||
                    session['courseCode'] == null ||
                    session['date'] == null) {
                  return const ListTile(
                    title: Text('Invalid session data'),
                    subtitle: Text('One or more fields are missing'),
                  );
                }

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: const Icon(Icons.class_, color: Colors.white),
                    ),
                    title: Text(
                      session['courseTitle'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                        'Course Code: ${session['courseCode']} \nDate: ${session['date']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.visibility,
                          color: Colors.blueAccent),
                      onPressed: () {
                        // Navigate to attendance details page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AttendanceDetailsPage(sessionId: session.id),
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
}
