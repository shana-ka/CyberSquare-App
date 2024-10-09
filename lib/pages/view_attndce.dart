import 'package:cybersquareapp/models/attndnc_model.dart';
import 'package:cybersquareapp/models/batch_model.dart';
import 'package:cybersquareapp/services/attndnc_firestore.dart';
import 'package:cybersquareapp/services/batch_firetsore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewAttendancePage extends StatefulWidget {
  String? batchName;
  DateTime date;
  ViewAttendancePage({super.key, this.batchName, required this.date});

  @override
  _ViewAttendancePageState createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  final BatchFirestoreService _batchService = BatchFirestoreService();
  final AttendanceFirestoreService _attendanceService =
      AttendanceFirestoreService();

  String? _selectedBatch;
  DateTime _selectedDate = DateTime.now();
  List<Attendance> _attendanceList = [];
  bool _isLoading = false;

  // Fetch attendance when batch and date are selected
  Future<void> _fetchAttendance() async {
    if (_selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a batch.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Attendance> attendanceList =
          await _attendanceService.getAttendanceByBatchAndDate(
        _selectedBatch!,
        _selectedDate,
      );

      setState(() {
        _attendanceList = attendanceList;
        _isLoading = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attendance: $error')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Open date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
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
                height: 150,
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
                        'VIEW ATTENDANCE',
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
            // Batch Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Card(
                child: ListTile(
                  title: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Select Batch',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 80),
                          Expanded(
                            child: StreamBuilder<List<Batch>>(
                              stream: _batchService.getBatches(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CircularProgressIndicator();
                                }

                                List<Batch> batches = snapshot.data!;
                                return DropdownButton<String>(
                                  isExpanded: true,
                                  // hint: const Text('Select Batch'),
                                  value: _selectedBatch,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBatch = newValue;
                                    });
                                  },
                                  items: batches.map((Batch batch) {
                                    return DropdownMenuItem<String>(
                                      value: batch.name,
                                      child: Text(batch.name),
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      // Date Picker
                      Row(
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
                          const SizedBox(width: 100),
                          Text(
                            DateFormat.yMMMd().format(_selectedDate),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                      // Fetch Attendance Button
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
                          onPressed: _fetchAttendance,
                          child: const Text('View Attendance',
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 59, 59, 59))),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
              ),
            ),

            // Attendance Table
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _attendanceList.isEmpty
                      ? const Center(
                          child: Text('No attendance records available.'))
                      : ListView.builder(
                          itemCount: _attendanceList.length,
                          itemBuilder: (context, index) {
                            final attendance = _attendanceList[index];
                            return SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 5.0, left: 8, right: 8),
                                child: Card(
                                  child: ListTile(
                                    title: Text(
                                      '${attendance.studentId}  :  ${attendance.name}',
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              Color.fromARGB(255, 59, 65, 63),
                                          fontStyle: FontStyle.italic),
                                    ),
                                    trailing: Text(
                                      attendance.isPresent
                                          ? 'Present'
                                          : 'Absent',
                                      style: TextStyle(
                                          color: attendance.isPresent
                                              ? const Color.fromARGB(
                                                  255, 40, 90, 41)
                                              : const Color.fromARGB(
                                                  255, 165, 63, 56),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
