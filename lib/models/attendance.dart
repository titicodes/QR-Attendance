import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String studentId;
  final String courseId;
  final DateTime timestamp;

  Attendance({required this.id, required this.studentId, required this.courseId, required this.timestamp});

  factory Attendance.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Attendance(
      id: doc.id,
      studentId: data['studentId'] ?? '',
      courseId: data['courseId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'courseId': courseId,
      'timestamp': Timestamp.now(),
    };
  }
}