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
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('sessions')
              .doc(sessionId)
              .collection('attendances')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var attendances = snapshot.data!.docs;

            return ListView.builder(
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                var attendance = attendances[index];

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
                    title: Text(attendance['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Registration Number: ${attendance['regNumber']}'),
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
