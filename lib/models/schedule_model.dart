class Schedule {
  final String? date;
  final List<String>? mentors;
  final Map<String, Map<String, bool>> scheduleMap;

  Schedule({this.date, this.mentors, required this.scheduleMap});

  factory Schedule.fromFirestore(Map<String, dynamic>? firestoreData) {
    if (firestoreData == null) {
      return Schedule(scheduleMap: {});
    }

    return Schedule(
      date: firestoreData['date'] ?? '',
      mentors: firestoreData['mentors'] != null
          ? List<String>.from(firestoreData['mentors'])
          : [],
      scheduleMap: (firestoreData['scheduleMap'] as Map<String, dynamic>).map(
        (mentor, schedule) {
          return MapEntry(
            mentor,
            Map<String, bool>.from(schedule as Map<dynamic, dynamic>),
          );
        },
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'mentors': mentors,
      'scheduleMap': scheduleMap,
    };
  }
}
