

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybersquareapp/models/student_model.dart';

class FirestoreService {
  final CollectionReference _studentsCollection =
      FirebaseFirestore.instance.collection('students');

  Stream<List<Student>> getStudents() {
    return _studentsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Student.fromDocument(doc)).toList();
    });
  }

  Stream<List<Student>> getStudentsByBatch(String batchName) {
    return _studentsCollection
        .where('batch', isEqualTo: batchName)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Student.fromDocument(doc)).toList());
  }

  Future<void> addStudent(Student student) async {
    try {
      await _studentsCollection.add(student.toMap());
      print('Student added successfully.');
    } catch (e) {
      print('Error adding student: $e');
    }
  }

  Future<void> updateStudent(String docId, Student student) async {
    try {
      await _studentsCollection.doc(docId).update(student.toMap());
      print('Student updated successfully');
    } catch (e) {
      print('Error updating student: $e');
    }
  }

  Future<void> deleteStudent(String docId) async {
    try {
      await _studentsCollection.doc(docId).delete();
      print('Student deleted successfully');
    } catch (e) {
      print('Error deleting student: $e');
    }
  }
}

