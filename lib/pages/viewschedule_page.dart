import 'package:cybersquareapp/services/schedule_firestore.dart';
import 'package:flutter/material.dart';

class ViewschedulePage extends StatefulWidget {
  final DateTime? date;
  const ViewschedulePage({super.key, required this.date});

  @override
  _ViewschedulePageState createState() => _ViewschedulePageState();
}

class _ViewschedulePageState extends State<ViewschedulePage> {
  DateTime? selectedDate;
  List<String> mentors = [];
  Map<String, Map<String, bool>> scheduleMap = {};

  final ScheduleFirestoreService _scheduleService = ScheduleFirestoreService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.date != null) {
      selectedDate = widget.date; // Set selectedDate if date is provided
      fetchSchedule(selectedDate!);
    }
  }

  Future<void> fetchSchedule(DateTime? date) async {
    if (date == null) return;

    setState(() {
      isLoading = true;
      mentors = [];
      scheduleMap = {};
    });

    try {
      final schedule = await _scheduleService.getSchedule(date);
      if (schedule != null) {
        setState(() {
          mentors = schedule.scheduleMap.keys.toList();
          scheduleMap = schedule.scheduleMap;
        });
      } else {
        setState(() {
          mentors = [];
          scheduleMap = {};
        });
      }
    } catch (e) {
      print('Error fetching schedule: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
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
                      padding: EdgeInsets.only(left: 8, bottom: 10.0),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Card(
                child: ListTile(
                  title: Row(
                    children: [
                      const Text(
                        'Select Date',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 110),
                      ElevatedButton(
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              selectedDate = pickedDate;
                              mentors = [];
                              scheduleMap = {};
                              fetchSchedule(selectedDate!); // Fetch new schedule
                            });
                          }
                        },
                        child: Text(
                          selectedDate != null
                              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                              : "Pick Date",
                          style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 76, 101, 92)),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Attendance Table
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : mentors.isEmpty
                      ? const Center(child: Text('Select a date to view schedule'))
                      : Padding(
                          padding: const EdgeInsets.only(
                              left: 15.0, top: 20, right: 15, bottom: 15),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              border: TableBorder.all(
                                color: const Color.fromARGB(255, 126, 139, 134),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              columnWidths: const {
                                0: FlexColumnWidth(1),
                                1: FlexColumnWidth(1),
                                2: FlexColumnWidth(1),
                                3: FlexColumnWidth(1),
                              },
                              children: [
                                // Header row
                                const TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('Mentors',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontStyle: FontStyle.italic,
                                              fontSize: 15)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('9:30-11:30',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('11:30-1:30',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text('2:30-4:30',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                    ),
                                  ],
                                ),

                                for (var mentor in mentors)
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                          mentor,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontStyle: FontStyle.italic),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Checkbox(
                                          value: scheduleMap[mentor]?['9:30-11:30'] ?? false,
                                          onChanged: null, // Read-only
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Checkbox(
                                          value: scheduleMap[mentor]?['11:30-1:30'] ?? false,
                                          onChanged: null,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Checkbox(
                                          value: scheduleMap[mentor]?['2:30-4:30'] ?? false,
                                          onChanged: null,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
