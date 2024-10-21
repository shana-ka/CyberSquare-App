import 'package:cybersquareapp/components/current_date.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cybersquareapp/services/mentor_firestore.dart';
import 'package:cybersquareapp/services/schedule_firestore.dart';
import 'package:cybersquareapp/models/mentor_model.dart';

class ViewSchedule extends StatefulWidget {
  String? mentorName;
  DateTime selectedDate;
  ViewSchedule({
    Key? key,
      this.mentorName,
     required this.selectedDate
  }) : super(key: key);

  @override
  State<ViewSchedule> createState() => _ViewScheduleState();
}

class _ViewScheduleState extends State<ViewSchedule> {
  final ScheduleFirestoreService _scheduleService = ScheduleFirestoreService();
  final MentorFirestoreService _mentorService = MentorFirestoreService();

  String? selectedMentor;
  DateTime? selectedDate;
  List<Mentor> _mentors = [];
  Map<String, Map<String, bool>> scheduleMap = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMentors();
    selectedDate = DateTime.now(); // Initialize with the current date
  }

  Future<void> _fetchMentors() async {
    final mentorStream = _mentorService.getMentors();
    mentorStream.listen((mentors) {
      setState(() {
        _mentors = mentors;
      });
    });
  }

  Future<void> _fetchSchedule() async {
    if (selectedDate == null || selectedMentor == null) return;

    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    setState(() {
      _isLoading = true;
    });

    try {
      final scheduleData =
          await _scheduleService.getSchedule(formattedDate, selectedMentor!);
      setState(() {
        scheduleMap = scheduleData;
        _isLoading = false;
      });
      if (scheduleMap.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('No schedule found for the selected date and mentor.')),
        );
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching schedule: $error')),
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
                          'VIEW SCHEDULE',
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
              // Mentor Dropdown and Date Selection
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
                                  });
                                },
                                items: _mentors.map((Mentor mentor) {
                                  return DropdownMenuItem<String>(
                                    value: mentor.name,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 233, 236, 235),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed:
                                (selectedMentor != null && selectedDate != null)
                                    ? _fetchSchedule
                                    : null,
                            child: const Text('View Schedule',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 59, 59, 59))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Schedule Table
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (scheduleMap.isNotEmpty)
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
                      const TableRow(children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Batch',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '9:30-11:30',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '11:30-2:30',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '2:30-4:30',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ]),
                      for (var batch in scheduleMap.keys)
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              batch,
                              style: const TextStyle(
                                  fontSize: 16, fontStyle: FontStyle.italic),
                            ),
                          ),
                          for (var timeSlot in [
                            '9:30-11:30',
                            '11:30-2:30',
                            '2:30-4:30'
                          ])
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Checkbox(
                                value: scheduleMap[batch]?[timeSlot] ?? false,
                                onChanged: null, 
                              ),
                            ),
                        ]),
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      'No schedule found for the selected date and mentor.'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
