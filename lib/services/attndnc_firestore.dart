import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybersquareapp/models/attndnc_model.dart';
import 'package:intl/intl.dart';

class AttendanceFirestoreService {
  final CollectionReference _attendanceCollection =
      FirebaseFirestore.instance.collection('attendance');

  Future<void> markAttendance(String batchName, Attendance attendance) async {
    try {
      await _attendanceCollection
          .doc(batchName)
          .collection(DateFormat('yyyy-MM-dd').format(attendance.date))
          .doc(attendance.studentId)
          .set(attendance.toMap());
    } catch (e) {
      throw Exception('Error saving attendance: $e');
    }
  }

  Future<List<Attendance>> getAttendanceByBatchAndDate(
      String batchName, DateTime date) async {
    try {
      QuerySnapshot snapshot = await _attendanceCollection
          .doc(batchName)
          .collection(DateFormat('yyyy-MM-dd').format(date))
          .get();

      return snapshot.docs
          .map((doc) =>
              Attendance.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error fetching attendance: $e');
    }
  }
}
