import 'package:cloud_firestore/cloud_firestore.dart';

class Mentor {
  final String? id;
  final String name;
  final String mentorId;
  final String dept;
  final String phone;
  final String email;
  final String exprnc;

  Mentor(
      {this.id,
      required this.name,
      required this.mentorId,
      required this.dept,
      required this.exprnc,
      required this.phone,
      required this.email});
  factory Mentor.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Mentor(
      id: doc.id,
      name: data['name'] ?? '',
      mentorId: data['mentorId'] ?? '',
      dept: data['dept'] ?? '',
      exprnc: data['exprnc'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mentorId': mentorId,
      'dept': dept,
      'exprnc': exprnc,
      'phone': phone,
      'email': email
    };
  }
}
