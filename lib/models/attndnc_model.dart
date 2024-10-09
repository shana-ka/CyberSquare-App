import 'package:cloud_firestore/cloud_firestore.dart'; 

class Attendance {
  final String studentId;
  final String name;
  final DateTime date;
  final bool isPresent;

  Attendance({
    required this.studentId,
    required this.name,
    required this.date,
    required this.isPresent,
  });

  factory Attendance.fromFirestore(Map<String, dynamic> data) {
    return Attendance(
      studentId: data['studentId'],
      name: data['name'],
      date: (data['date'] as Timestamp).toDate(),
      isPresent: data['isPresent'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'name': name,
      'date': date,
      'isPresent': isPresent,
    };
  }
}
