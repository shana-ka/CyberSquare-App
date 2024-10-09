import 'package:cybersquareapp/components/calendar_date.dart';
import 'package:cybersquareapp/models/mentor_model.dart';
import 'package:cybersquareapp/pages/viewschedule_page.dart';
import 'package:cybersquareapp/services/mentor_firestore.dart';
import 'package:cybersquareapp/services/schedule_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key, required List<Mentor> mentors});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime? selectedDate;
  final ScheduleFirestoreService _scheduleService = ScheduleFirestoreService();
  final FirestoreService mentorService = FirestoreService();
  Map<String, Map<String, bool>> scheduleMap = {};

  Future<void> _submitSchedule() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    try {
      await _scheduleService.submitSchedule(formattedDate, scheduleMap);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Schedule submitted successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting schedule: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Container
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 198, 210, 204),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'MENTOR\'S SCHEDULE',
                      style: TextStyle(
                        color: Color.fromARGB(255, 254, 255, 254),
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                      ),
                    ),
                  ),
                ),
              ),
              // Date Selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                child: Card(
                  child: ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 115),
                        CalendarDateWidget(
                          onDateSelected: (DateTime date) {
                            setState(() {
                              selectedDate = date;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Schedule table
              StreamBuilder<List<Mentor>>(
                stream: mentorService.getMentors(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching mentors'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No mentors available'));
                  }

                  final mentors = snapshot.data!;

                  for (var mentor in mentors) {
                    if (!scheduleMap.containsKey(mentor.name)) {
                      scheduleMap[mentor.name] = {
                        '9:30-11:30': false,
                        '11:30-1:30': false,
                        '2:30-4:30': false,
                      };
                    }
                  }

                  scheduleMap.removeWhere((mentorName, _) =>
                      !mentors.any((m) => m.name == mentorName));

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12.0, vertical: 8.0),
                    child: Table(
                      border: TableBorder.all(
                          color: const Color.fromARGB(255, 126, 139, 134)),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        const TableRow(children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Mentors',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('9:30-11:30',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('11:30-1:30',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('2:30-4:30',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ]),
                        // Row for each mentor
                        for (var mentor in mentors)
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                mentor.name,
                                style: const TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                            ),
                            for (var slot in [
                              '9:30-11:30',
                              '11:30-1:30',
                              '2:30-4:30'
                            ])
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: Checkbox(
                                  activeColor:
                                      const Color.fromARGB(255, 170, 182, 177),
                                  value:
                                      scheduleMap[mentor.name]?[slot] ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      scheduleMap[mentor.name]?[slot] =
                                          value ?? false;
                                    });
                                  },
                                ),
                              ),
                          ]),
                      ],
                    ),
                  );
                },
              ),
              // Submit button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _submitSchedule,
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 59, 59, 59)),
                  ),
                ),
              ),
              // View Schedule button
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const ViewschedulePage(date: null),
                      ),
                    );
                  },
                  child: const Text(
                    'View schedule',
                    style: TextStyle(
                        fontSize: 16, color: Color.fromARGB(255, 59, 59, 59)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
