import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewAttendancePage extends StatelessWidget {
  final String regNumber;

  const ViewAttendancePage({super.key, required this.regNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Attendance')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collectionGroup('attendances').where('regNumber', isEqualTo: regNumber).snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            var attendances = snapshot.data!.docs;

            return ListView.builder(
              itemCount: attendances.length,
              itemBuilder: (context, index) {
                var attendance = attendances[index];
                return FutureBuilder<DocumentSnapshot>(
                  future: attendance.reference.parent.parent!.get(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> sessionSnapshot) {
                    if (!sessionSnapshot.hasData) {
                      return const ListTile(
                        title: Text('Loading...'),
                      );
                    }

                    var sessionData = sessionSnapshot.data!.data() as Map<String, dynamic>;

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
                        title: Text(attendance['studentName'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Course: ${sessionData['courseTitle']}'),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
