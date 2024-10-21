import 'package:cybersquareapp/models/batch_model.dart';
import 'package:cybersquareapp/models/student_model.dart';
import 'package:cybersquareapp/services/batch_firetsore.dart';
import 'package:cybersquareapp/services/student_firestore.dart';
import 'package:flutter/material.dart';

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<Student> allStudents = [];
  List<Student> filteredStudents = [];
  String? selectedBatch;

  @override
  void initState() {
    super.initState();
    // Fetch all students initially
    firestoreService.getStudents().listen((students) {
      setState(() {
        allStudents = students;
        filteredStudents = allStudents; // Show all students initially
      });
    });
  }

  // Method to filter students based on batch selection
  void filterStudentsByBatch(String? batchName) {
    setState(() {
      if (batchName == null || batchName.isEmpty) {
        filteredStudents =
            allStudents; // If no batch is selected, show all students
      } else {
        filteredStudents =
            allStudents.where((student) => student.batch == batchName).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 250, 250),
      body: SafeArea(
        child: StreamBuilder<List<Student>>(
          stream: firestoreService.getStudents(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final students = snapshot.data ?? [];

            return SingleChildScrollView(
              child: SafeArea(
                child: Column(
                  children: [
                    Container(
                      height: 180,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 100.0),
                        child: Image.asset(
                          'lib/images/studlap-removebg-preview.png',
                          width: 260,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 15.0),
                          child: Text(
                            'Students',
                            style: TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 148, 165, 159),
                            ),
                          ),
                        ),
                        const SizedBox(width: 90),
                        TextButton(
                          onPressed: () => _showStudentDialog(context, null),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.person_add_alt_1,
                                color: Color.fromARGB(255, 80, 93, 99),
                              ),
                              SizedBox(width: 7),
                              Text(
                                'Add Student',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromARGB(255, 61, 81, 90),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Container(
                        height: 600,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(9),
                          color: const Color.fromARGB(255, 232, 233, 233),
                        ),
                        child: ListView.builder(
                          itemCount: students.length,
                          itemBuilder: (context, index) {
                            final student = students[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 10.0, left: 8, right: 8),
                              child: Card(
                                color: const Color.fromARGB(255, 251, 250, 250),
                                elevation: 3,
                                child: ListTile(
                                  title: Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ID : ${student.studId} \nPhone : ${student.phone} \nCourse : ${student.course} \nBatch : ${student.batch} \nE-mail : ${student.email}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => _showStudentDialog(
                                            context, student),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          if (student.id != null) {
                                            firestoreService
                                                .deleteStudent(student.id!);
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                                    content: Text(
                                                        'No document ID found for student')));
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showStudentDialog(BuildContext context, Student? student) {
    final TextEditingController nameController =
        TextEditingController(text: student?.name ?? '');
    final TextEditingController studIdController =
        TextEditingController(text: student?.studId ?? '');
    final TextEditingController courseController =
        TextEditingController(text: student?.course ?? '');
    // final TextEditingController batchController = TextEditingController(text: student?.batch ?? '');
    final TextEditingController phoneController =
        TextEditingController(text: student?.phone ?? '');
    final TextEditingController emailController =
        TextEditingController(text: student?.email ?? '');
    String? selectedBatch = student?.batch;
    final BatchFirestoreService batchService = BatchFirestoreService();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student == null ? 'Add Student' : 'Edit Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: nameController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Student ID'),
                  controller: studIdController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Course Name'),
                  controller: courseController,
                ),
                // TextField(
                //   decoration: InputDecoration(labelText: 'Batch'),
                //   controller: batchController,
                // ),
                StreamBuilder<List<Batch>>(
                  stream: batchService.getBatches(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    List<Batch> batches = snapshot.data!;
                    if (batches.isEmpty) {
                      return const Text('No batches available');
                    }

                    return DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Select Batch'),
                      value: selectedBatch,
                      items: batches.map((Batch batch) {
                        return DropdownMenuItem<String>(
                          value: batch.name,
                          child: Text(batch.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        selectedBatch = newValue;
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a batch';
                        }
                        return null;
                      },
                    );
                  },
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Contact No'),
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(student == null ? 'Add' : 'Save Changes'),
              onPressed: () {
                final name = nameController.text;
                final studId = studIdController.text;
                final course = courseController.text;
                // final batch = batchController.text;
                final batch = selectedBatch;
                final phone = phoneController.text;
                final email = emailController.text;

                if (name.isNotEmpty &&
                    studId.isNotEmpty &&
                    course.isNotEmpty &&
                    // batch.isNotEmpty &&
                    batch != null &&
                    phone.isNotEmpty &&
                    email.isNotEmpty) {
                  final studentData = Student(
                    id: student?.id, // Preserve ID for updates
                    name: name,
                    studId: studId,
                    course: course,
                    batch: batch,
                    phone: phone,
                    email: email,
                  );
                  if (student == null) {
                    firestoreService.addStudent(studentData);
                  } else {
                    firestoreService.updateStudent(student.id!, studentData);
                  }
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All fields are required')));
                }
              },
            ),
          ],
        );
      },
    );
  }
}
