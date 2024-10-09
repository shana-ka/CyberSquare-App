import 'package:cybersquareapp/models/attndnc_model.dart';
import 'package:cybersquareapp/models/student_model.dart';
import 'package:cybersquareapp/models/batch_model.dart';
import 'package:cybersquareapp/pages/view_attndce.dart';
import 'package:cybersquareapp/services/attndnc_firestore.dart';
import 'package:cybersquareapp/services/student_firestore.dart';
import 'package:cybersquareapp/services/batch_firetsore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final FirestoreService _studentService = FirestoreService();
  final BatchFirestoreService _batchService = BatchFirestoreService();

  String? _selectedBatch;
  List<Student> _students = [];
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> _attendanceMap = {}; // Map to track attendance

  // Fetch students when a batch is selected
  Future<void> _fetchStudents(String batchName) async {
    List<Student> students =
        await _studentService.getStudentsByBatch(batchName).first;

    setState(() {
      _students = students;
      // Initialize the attendance map with default values (e.g., false)
      _attendanceMap = {
        for (var student in students) student.studId: false,
      };
    });
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

  void _saveAttendance() async {
    if (_selectedBatch == null || _students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a batch and mark attendance')),
      );
      return;
    }

    // Save attendance for each student in Firestore
    for (var entry in _attendanceMap.entries) {
      String studentId = entry.key;
      bool isPresent = entry.value;
      String name =
          _students.firstWhere((student) => student.studId == studentId).name;

      Attendance attendance = Attendance(
        studentId: studentId,
        name: name,
        date: _selectedDate,
        isPresent: isPresent,
      );

      await AttendanceFirestoreService()
          .markAttendance(_selectedBatch!, attendance);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved successfully!')),
    );
  }

  void _viewAttendance() {
    // if (_selectedBatch == null || _students.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //         content: Text('Please select a batch to view attendance')),
    //   );
    //   return;
    // }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ViewAttendancePage(batchName: _selectedBatch, date: _selectedDate),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(  
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
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
                        'STUDENT\'S ATTENDANCE',
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                  value: _selectedBatch,
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 30,
                                  ),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedBatch = newValue;
                                    });
                                    if (newValue != null) {
                                      _fetchStudents(newValue);
                                    }
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
                          Text(DateFormat.yMMMd().format(_selectedDate)),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                        ],
                      ),
                    ],
                  ),
        
                 
                ),
              ),
            ),
        
            // Attendance Table with Checkboxes
            Expanded(
              child: _students.isEmpty
                  ? const Center(
                      child: Text('No students available for this batch.'))
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8,right: 8),
                            child: Card(
                              child: ListTile(
                                title: Text('${student.studId}   :   ${student.name}', style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromARGB(255, 18, 28, 24),
                                              fontStyle: FontStyle.italic
                                              ),
                                              ),
                                trailing: Checkbox(
                                  activeColor:const Color.fromARGB(255, 170, 182, 177) ,
                                  value: _attendanceMap[student.studId],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _attendanceMap[student.studId] = value ?? false;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
        
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _saveAttendance,
              child: const Text(
                'SUBMIT',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 59, 59, 59)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _viewAttendance,
                child: const Text(
                  'View Attendance',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 59, 59, 59)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
