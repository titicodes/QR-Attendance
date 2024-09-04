
import 'package:cloud_firestore/cloud_firestore.dart';

class Course {
  final String id;
  final String title;
  final String code;
  final String duration;

  Course({required this.id, required this.title, required this.code, required this.duration});

  factory Course.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Course(
      id: doc.id,
      title: data['title'] ?? '',
      code: data['code'] ?? '',
      duration: data['duration'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'code': code,
      'duration': duration,
    };
  }
}

