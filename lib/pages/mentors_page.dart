import 'package:cybersquareapp/models/mentor_model.dart';
import 'package:cybersquareapp/services/mentor_firestore.dart';
import 'package:flutter/material.dart';

class MentorsPage extends StatefulWidget {
  const MentorsPage({super.key});

  @override
  State<MentorsPage> createState() => _MentorsPageState();
}

class _MentorsPageState extends State<MentorsPage> {
  final MentorFirestoreService firestoreService = MentorFirestoreService();
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 250, 250),
      body: StreamBuilder<List<Mentor>>(
        stream: firestoreService.getMentors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          List<Mentor> mentors = snapshot.data ?? [];

          return SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 200,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 100.0),
                      child: Image.asset(
                        'lib/images/mentoring-removebg-preview.png',
                        width: 250,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Text(
                          'Mentors',
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 137, 173, 189),
                          ),
                        ),
                      ),
                      const SizedBox(width: 100),
                      TextButton(
                        onPressed: () => _showMentorDialog(context, null),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.person_add_alt_1,
                              color: Color.fromARGB(255, 80, 93, 99),
                            ),
                            SizedBox(width: 7),
                            Text(
                              'Add Mentor',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: Color.fromARGB(255, 61, 81, 90),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                        itemCount: mentors.length,
                        itemBuilder: (context, index) {
                          final mentor = mentors[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, left: 8, right: 8),
                            child: Card(
                              color: const Color.fromARGB(255, 251, 250, 250),
                              elevation: 3,
                              child: ListTile(
                                title: Text(
                                  mentor.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  'ID: ${mentor.mentorId}\n'
                                  'Department: ${mentor.dept}\n'
                                  'Experience: ${mentor.exprnc}\n'
                                  'Phone: ${mentor.phone}\n'
                                  'E-mail: ${mentor.email}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () {
                                        _showMentorDialog(context, mentor);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        if (mentor.id != null) {
                                          firestoreService
                                              .deleteMentor(mentor.id!);
                                        } else {
                                          print(
                                              'No document ID found for mentor');
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
    );
  }

  void _showMentorDialog(BuildContext context, Mentor? mentor) {
    final TextEditingController nameController =
        TextEditingController(text: mentor?.name ?? '');
    final TextEditingController mentorIdController =
        TextEditingController(text: mentor?.mentorId ?? '');
    final TextEditingController deptController =
        TextEditingController(text: mentor?.dept ?? '');
    final TextEditingController exprncController =
        TextEditingController(text: mentor?.exprnc ?? '');
    final TextEditingController phoneController =
        TextEditingController(text: mentor?.phone ?? '');
    final TextEditingController emailController =
        TextEditingController(text: mentor?.email ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(mentor == null ? 'Add Mentor' : 'Edit Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  controller: nameController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Mentor ID'),
                  controller: mentorIdController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Department'),
                  controller: deptController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Experience'),
                  controller: exprncController,
                ),
                TextField(
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  onChanged: (value) {
                    if (value.length != 10) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('minimum 10 digits required')),
                      );
                    }
                  },
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
              child: Text(mentor == null ? 'Add' : 'Save Changes'),
              onPressed: () {
                final name = nameController.text;
                final mentorId = mentorIdController.text;
                final dept = deptController.text;
                final exprnc = exprncController.text;
                final phone = phoneController.text;
                final email = emailController.text;

                if (name.isNotEmpty &&
                    mentorId.isNotEmpty &&
                    dept.isNotEmpty &&
                    exprnc.isNotEmpty &&
                    phone.isNotEmpty &&
                    email.isNotEmpty) {
                  final mentorData = Mentor(
                    id: mentor?.id,
                    name: name,
                    mentorId: mentorId,
                    dept: dept,
                    exprnc: exprnc,
                    phone: phone,
                    email: email,
                  );
                  if (mentor == null) {
                    firestoreService.addMentor(mentorData);
                  } else {
                    firestoreService.updateMentor(mentor.id!, mentorData);
                  }
                  Navigator.of(context).pop();
                } else {
                  print('All fields are required');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
