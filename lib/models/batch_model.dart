import 'package:cloud_firestore/cloud_firestore.dart';

class Batch {
  final String? id;
  final String name;
  final String course;
  final String duration;
  final String mentorName;
  // final int? noStud;
  // final List<String> students;
  // Timestamp timestamp; // Add this field

  Batch({
    this.id,
    required this.name,
    required this.course,
    required this.mentorName,
    required this.duration,
    // this.noStud,
    // required this.students,
    // required this.timestamp,
  });

  factory Batch.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return Batch(
        id: doc.id,
        name: data['name'] ?? '',
        course: data['course'] ?? '',
        mentorName: data['mentorName']??'',
        duration: data['duration']??'',
        // noStud: data['noStud'] ?? 0,
        // students: List<String>.from(data['students'] ?? []),
        // timestamp: data['timestamp']
        );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'course': course,
      'duration':duration,
      'mentorName':mentorName
      // 'noStud': noStud,
      // 'students': students,
      // 'timestamp': timestamp
    };
  }
}
