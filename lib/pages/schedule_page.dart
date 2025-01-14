import 'package:cybersquareapp/components/current_date.dart';
import 'package:cybersquareapp/models/batch_model.dart';
import 'package:cybersquareapp/models/mentor_model.dart';
import 'package:cybersquareapp/pages/view_schedule.dart';
import 'package:cybersquareapp/services/batch_firetsore.dart';
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
  final MentorFirestoreService _mentorService = MentorFirestoreService();
  final BatchFirestoreService _batchService = BatchFirestoreService();

  String? selectedMentor;
  List<Batch> mentorBatches = [];
  DateTime? selectedDate;
  final ScheduleFirestoreService _scheduleService = ScheduleFirestoreService();
  List<Mentor> _mentors = [];

  // Time slots and schedule map
  final List<String> _timeSlots = ['9:30-11:30', '11:30-2:30', '2:30-4:30'];
  Map<String, Map<String, bool>> scheduleMap =
      {}; // Maps batch -> (timeSlot -> marked/unmarked)

  @override
  void initState() {
    super.initState();
    _fetchMentors();
    selectedDate = DateTime.now();
  }

  Future<void> _fetchMentors() async {
    final mentorStream = _mentorService.getMentors();
    mentorStream.listen((mentors) {
      setState(() {
        _mentors = mentors;
      });
    });
  }

  void _fetchBatchesForMentor(String mentorName) async {
    mentorBatches.clear();
    scheduleMap.clear();

    Stream<List<Batch>> batchStream =
        _batchService.getBatchesByMentor(mentorName);
    batchStream.listen((batches) {
      setState(() {
        mentorBatches = batches;

        for (var batch in mentorBatches) {
          if (!scheduleMap.containsKey(batch.name)) {
            scheduleMap[batch.name] = {
              for (var slot in _timeSlots) slot: false,
            };
          }
        }
      });
    });
  }

  Future<void> _submitSchedule() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date')),
      );
      return;
    }
    if (selectedMentor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mentor')),
      );
      return;
    }

    if (scheduleMap.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please mark at least one time slot')),
      );
      return;
    }

    // Format the selected date as a string
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);

    try {
      await _scheduleService.submitSchedule(
          selectedMentor!, formattedDate, scheduleMap);
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
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 15.0),
                        child: Text(
                          'MENTOR\'S SCHEDULE',
                          style: TextStyle(
                            color: Color.fromARGB(255, 254, 255, 254),
                            fontWeight: FontWeight.bold,
                            fontSize: 27,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Date Selection and Mentor Dropdown
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 7.0),
                child: Card(
                  child: ListTile(
                    title: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Select Mentor',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w400,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 80),
                            Expanded(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedMentor,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  size: 30,
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedMentor = newValue;
                                    mentorBatches
                                        .clear(); 
                                    if (newValue != null) {
                                      _fetchBatchesForMentor(newValue);
                                    }
                                  });
                                },
                                items: _mentors.map((Mentor mentor) {
                                  return DropdownMenuItem<String>(
                                    value: mentor.name, // Use mentor name
                                    child: Text(mentor.name),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        Row(
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
                              initialDate: selectedDate,
                              onDateSelected: (DateTime date) {
                                setState(() {
                                  selectedDate = date;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Batch and Time Slots Table
              if (mentorBatches.isNotEmpty)
                Padding(
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
                      TableRow(children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Batch',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        for (var slot in _timeSlots)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              slot,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                      ]),
                      for (var batch in mentorBatches)
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              batch.name,
                              style: const TextStyle(
                                  fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          ),
                          for (var slot in _timeSlots)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Checkbox(
                                activeColor:
                                    const Color.fromARGB(255, 170, 182, 177),
                                value: scheduleMap[batch.name]?[slot] ?? false,
                                onChanged: (bool? value) {
                                  setState(() {
                                    scheduleMap[batch.name]?[slot] =
                                        value ?? false;
                                  });
                                },
                              ),
                            ),
                        ]),
                    ],
                  ),
                ),
              // Submit and View Schedule buttons
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed:_submitSchedule,
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 59, 59, 59),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0,right: 10),
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
                        builder: (context) => ViewSchedule(
                          mentorName: selectedMentor,
                          selectedDate: selectedDate!,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'View Scehdule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 59, 59, 59),
                    ),
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
