import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceDetailsPage extends StatelessWidget {
  final String sessionId;

  const AttendanceDetailsPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('class_sessions')
              .doc(sessionId)
              .collection('attendances')
              .snapshots(),
          builder: (context, snapshot) {
            // Show loading indicator while waiting for data
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle error in snapshot
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Handle case where there's no data or the subcollection is empty
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No attendance records found.'));
            }

            // If data is available, proceed to display it
            var attendances = snapshot.data!.docs;

            return ListView.builder(
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                var attendance = attendances[index];

                // Debugging check: Print out the data for each attendance document
                print('Attendance Data: ${attendance.data()}');

                // Check if the expected fields exist before displaying
                if (attendance['studentName'] == null || attendance['regNumber'] == null) {
                  return const ListTile(
                    title: Text('Invalid data'),
                    subtitle: Text('Missing fields'),
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
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(attendance['studentName'],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text('Registration Number: ${attendance['regNumber']}'),
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
