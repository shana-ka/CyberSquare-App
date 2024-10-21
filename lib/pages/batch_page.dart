import 'package:cybersquareapp/models/batch_model.dart';
import 'package:cybersquareapp/models/mentor_model.dart';
import 'package:cybersquareapp/models/student_model.dart';
import 'package:cybersquareapp/services/batch_firetsore.dart';
import 'package:cybersquareapp/services/mentor_firestore.dart';
import 'package:cybersquareapp/services/student_firestore.dart';
import 'package:flutter/material.dart';

class BatchPage extends StatefulWidget {
  const BatchPage({super.key});

  @override
  State<BatchPage> createState() => _BatchPageState();
}

class _BatchPageState extends State<BatchPage> {
  final BatchFirestoreService _batchService = BatchFirestoreService();

  Stream<List<Batch>> fetchBatches() {
    return _batchService.getBatches();
  }

  Future<String> getNextBatchName() async {
    int currentNumber = await _batchService.getBatchCount() + 1;
    return 'B${currentNumber.toString().padLeft(2, '0')}';
  }

  Future<void> _showBatchDialog({Batch? batch, String? docId}) async {
    bool isEditMode = batch != null;
    TextEditingController courseController =
        TextEditingController(text: isEditMode ? batch!.course : '');
    final List<String> durations = [
      '1 Month',
      '3 Months',
      '6 Months',
      '1 Year'
    ];
    String selectedDuration = isEditMode ? batch!.duration : durations[0];
    String selectedMentor = isEditMode ? batch!.mentorName : '';

    final MentorFirestoreService mentorService = MentorFirestoreService();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:
              Text(isEditMode ? 'Edit Batch ${batch!.name}' : 'Add New Batch'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: courseController,
                decoration: const InputDecoration(labelText: 'Course Name'),
              ),
              StreamBuilder<List<Mentor>>(
                stream: mentorService.getMentors(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  List<Mentor> mentors = snapshot.data!;
                  if (mentors.isEmpty) {
                    return const Text('No mentors available');
                  }

                  return DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Mentor'),
                    value: selectedMentor.isNotEmpty ? selectedMentor : null,
                    items: mentors.map((Mentor mentor) {
                      return DropdownMenuItem<String>(
                        value: mentor.name,
                        child: Text(mentor.name),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedMentor = newValue!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a mentor';
                      }
                      return null;
                    },
                  );
                },
              ),
              DropdownButtonFormField<String>(
                value: selectedDuration,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: durations.map((String duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Text(duration),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDuration = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a duration';
                  }
                  return null;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(isEditMode ? 'Save' : 'Add Batch'),
              onPressed: () async {
                String courseName = courseController.text;

                if (isEditMode) {
                  if (docId != null) {
                    await _batchService.updateBatch(
                      docId,
                      Batch(
                        id: batch!.id,
                        name: batch!.name,
                        course: courseName,
                        mentorName: selectedMentor,
                        duration: selectedDuration,
                      ),
                    );
                  }
                } else {
                  // Add new batch
                  String nextBatchName = await getNextBatchName();
                  await _batchService.addBatch(
                    Batch(
                      id: '',
                      name: nextBatchName,
                      course: courseName,
                      mentorName: selectedMentor,
                      duration: selectedDuration,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showStudentsByBatch(BuildContext context, String batchName) {
    final FirestoreService studentService = FirestoreService();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
              child: Text(
            'Students in $batchName',
            style: const TextStyle(fontWeight: FontWeight.w500),
          )),
          content: StreamBuilder<List<Student>>(
            stream: studentService.getStudentsByBatch(batchName),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Error fetching students');
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Student> students = snapshot.data!;

              if (students.isEmpty) {
                return const Text('No students found in this batch.');
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: students.map((
                  student,
                ) {
                  return Text('${student.studId} : ${student.name}',
                      style: const TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w400));
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Batch>>(
            stream: fetchBatches(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching batches'));
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              List<Batch> batches = snapshot.data!;
              if (batches.isEmpty) {
                return const Center(child: Text('No batches found'));
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 215, 220, 225),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 100.0, left: 25),
                        child: Text(
                          'BATCHES',
                          style: TextStyle(
                            color: Color.fromARGB(255, 254, 254, 255),
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Existing Batches',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 101, 95, 95),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: ListView.builder(
                        itemCount: batches.length,
                        itemBuilder: (context, index) {
                          final batch = batches[index];
                          return Card(
                            child: ListTile(
                              leading: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: const Color.fromARGB(
                                          255, 215, 220, 225)),
                                  height: 50,
                                  width: 50,
                                  child: Center(
                                      child: Text(
                                    batch.name,
                                    style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontStyle: FontStyle.italic),
                                  ))),
                              title: Text(
                                batch.course,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  'Duration : ${batch.duration}\nMentor : ${batch.mentorName}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                      child: const Text(
                                        'View',
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 64, 60, 60)),
                                      ),
                                      onPressed: () {
                                        _showStudentsByBatch(context,
                                            batch.name); // Update this line
                                      }),
                                  IconButton(
                                      onPressed: () async {
                                        if (batch.id != null) {
                                          await _batchService
                                              .deleteBatch(batch.id!);
                                        }
                                      },
                                      icon: const Icon(Icons.delete)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBatchDialog();
        },
        backgroundColor: const Color.fromARGB(255, 215, 220, 225),
        foregroundColor: const Color.fromARGB(255, 254, 254, 255),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
