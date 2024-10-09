
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybersquareapp/models/schedule_model.dart';

class ScheduleFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get stream of mentor names in real-time
  Stream<List<String>> getMentorsStream() {
    return _firestore.collection('mentors').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  // Save schedule for the selected date
  Future<void> submitSchedule(
      String date, Map<String, Map<String, bool>> scheduleMap) async {
    try {
      await _firestore
          .collection('schedules')
          .doc(date)
          .set({'date': date, 'scheduleMap': scheduleMap});
      print("Schedule submitted successfully");
    } catch (e) {
      print("Error submitting schedule: $e");
    }
  }

  // Fetch schedule for a specific date
  Future<Schedule?> getSchedule(DateTime date) async {
    String formattedDate =
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('schedules').doc(formattedDate).get();

      if (snapshot.exists && snapshot.data() != null) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

        Map<String, Map<String, bool>> scheduleMap =
            (data['scheduleMap'] as Map<String, dynamic>).map(
          (mentor, schedule) =>
              MapEntry(mentor, Map<String, bool>.from(schedule)),
        );

        // Return the Schedule object
        return Schedule(
          date: data['date'] ??
              formattedDate, // Use the date from Firestore or fallback
          mentors: scheduleMap.keys.toList(),
          scheduleMap: scheduleMap,
        );
      } else {
        print('No schedule data found for this date');
        return null;
      }
    } catch (e) {
      print('Error fetching schedule: $e');
      return null;
    }
  }
}
