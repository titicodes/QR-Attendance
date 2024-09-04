import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SystemStatisticsPage extends StatelessWidget {
  const SystemStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('System Statistics',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildStatisticCard(context, 'Total Users', _getTotalUsers()),
                  _buildStatisticCard(
                      context, 'Total Courses', _getTotalCourses()),
                  _buildStatisticCard(context, 'Total Attendance Records',
                      _getTotalAttendanceRecords()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticCard(
      BuildContext context, String title, Future<int> countFuture) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.analytics, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: FutureBuilder<int>(
          future: countFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const CircularProgressIndicator();
            }
            return Text(
              snapshot.data.toString(),
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary),
            );
          },
        ),
      ),
    );
  }

  Future<int> _getTotalUsers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();
    return querySnapshot.size;
  }

  Future<int> _getTotalCourses() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    return querySnapshot.size;
  }

  Future<int> _getTotalAttendanceRecords() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('attendance').get();
    return querySnapshot.size;
  }
}