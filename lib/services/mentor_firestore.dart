import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybersquareapp/models/mentor_model.dart';

class MentorFirestoreService {
  final CollectionReference _mentorsCollection =
      FirebaseFirestore.instance.collection('mentors');

  Stream<List<Mentor>> getMentors() {
    return _mentorsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Mentor.fromDocument(doc)).toList();
    });
  }

  Future<void> addMentor(Mentor mentor) async {
    try {
      await _mentorsCollection.add(mentor.toMap());
      print('Mentor added successfully.');
    } catch (e) {
      print('Error adding mentor: $e');
    }
  }

  Future<void> updateMentor(String docId, Mentor mentor) async {
    try {
      await _mentorsCollection.doc(docId).update(mentor.toMap());
      print('Mentor updated successfully');
    } catch (e) {
      print('Error updating mentor: $e');
    }
  }

  Future<void> deleteMentor(String docId) async {
    try {
      await _mentorsCollection.doc(docId).delete();
      print('Mentor deleted successfully');
    } catch (e) {
      print('Error deleting mentor: $e');
    }
  }
}
