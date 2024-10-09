import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybersquareapp/models/batch_model.dart';
import 'package:cybersquareapp/models/student_model.dart';

class BatchFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final CollectionReference _batchCollection = FirebaseFirestore.instance.collection('batches');


  // Fetch all batches from Firestore
  Stream<List<Batch>> getBatches() {
    return _firestore.collection('batches').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Batch.fromDocument(doc)).toList();
    });
  }

  Future<List<String>> getStudentsFromBatch(String batchId) async {
  try {
    DocumentSnapshot batchSnapshot = await FirebaseFirestore.instance.collection('batches').doc(batchId).get();
    
    if (batchSnapshot.exists) {
      // Assuming the batch document contains a 'students' field, which is a list of student names
      List<dynamic> students = batchSnapshot.get('students');
      return students.cast<String>();
    }
    return [];
  } catch (error) {
    print('Error fetching students from batch: $error');
    return [];
  }
}


    // Get the count of documents in the 'batches' collection
  Future<int> getBatchCount() async {
    QuerySnapshot snapshot = await _batchCollection.get();
    return snapshot.docs.length;
  }

  // get name of studednts in a batch
  Stream<List<Student>> getStudentsByBatch(String batchName) {
  return FirebaseFirestore.instance
      .collection('students')
      .where('batch', isEqualTo: batchName)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Student.fromDocument(doc)).toList());
}

  // Add a new batch to Firestore
  Future<void> addBatch(Batch batch) async {
    try {
      await _firestore.collection('batches').add(batch.toMap());
      print('Batch added successfully.');
    } catch (e) {
      print('Error adding batch: $e');
    }
  }

  // Update an existing batch in Firestore
  Future<void> updateBatch(String docId, Batch updatedBatch) async {
    try {
      await _firestore
          .collection('batches')
          .doc(docId)
          .update(updatedBatch.toMap());
      print('Batch updated successfully');
    } catch (e) {
      print('Error updating batch: $e');
    }
  }

  // Delete a batch from Firestore
  Future<void> deleteBatch(String docId) async {
    try {
      await _firestore.collection('batches').doc(docId).delete();
      print('Batch deleted successfully');
    } catch (e) {
      print('Error deleting batch: $e');
      
    }
  }
}
