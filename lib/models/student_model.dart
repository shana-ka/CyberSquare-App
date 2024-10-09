
import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String? id; // Add this to store the Firestore document ID
  final String name;
  final String studId;
  final String course;
  final String batch;
  final String phone;
  final String email;

  Student({
    this.id,
    required this.name,
    required this.studId,
    required this. course,
    required this.batch,
    required this.phone,
    required this.email,
  });

  factory Student.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Student(
      id: doc.id, // Set the document ID
      name: data['name'] ?? '',
      studId: data['studId'] ?? '',
      course: data['course']??'',
      batch:data['batch']??'',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'studId': studId,
      'course':course,
      'batch':batch,
      'phone': phone,
      'email': email,
    };
  }
}
