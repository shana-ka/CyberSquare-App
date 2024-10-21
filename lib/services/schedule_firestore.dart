import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> submitSchedule(
    String mentorName, String formattedDate, Map<String, Map<String, bool>> scheduleMap) async {
    DocumentReference scheduleRef = _db.collection('schedules').doc('$mentorName-$formattedDate');

    Map<String, dynamic> data = {
      'mentorName': mentorName,
      'date': formattedDate,
      'schedule': {}
    };

    // Populate the schedule data
    for (var batch in scheduleMap.keys) {
      data['schedule'][batch] = scheduleMap[batch];
    }

    // Set the data in Firestore
    await scheduleRef.set(data, SetOptions(merge: true));
  }

  // Get Schedule
  Future<Map<String, Map<String, bool>>> getSchedule(String formattedDate, String mentorName) async {
    DocumentReference scheduleRef = _db.collection('schedules').doc('$mentorName-$formattedDate');
    
    DocumentSnapshot snapshot = await scheduleRef.get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      Map<String, Map<String, bool>> scheduleMap = {};

      // Populate the schedule map from Firestore data
      if (data['schedule'] != null) {
        scheduleMap = (data['schedule'] as Map).map((key, value) =>
            MapEntry(key, (value as Map).map((k, v) => MapEntry(k, v as bool))));
      }
      
      return scheduleMap;
    } else {
      return {};
    }
  }
}

