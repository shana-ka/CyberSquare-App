import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybersquareapp/components/my_container.dart';
import 'package:cybersquareapp/models/mentor_model.dart';
import 'package:cybersquareapp/pages/attendnce_page.dart';
import 'package:cybersquareapp/pages/batch_page.dart';
import 'package:cybersquareapp/pages/mentors_page.dart';
import 'package:cybersquareapp/pages/schedule_page.dart';
import 'package:cybersquareapp/pages/students_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
 const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String _userName = ''; 
  List<Mentor>mentors=[];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _fetchMentors();
  }

 Future<void> _fetchMentors() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('mentors').get();
      setState(() {
        mentors = snapshot.docs
            .map((doc) => Mentor.fromDocument(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching mentors: $e');
    }
  }


  Future<void> _loadUserInfo() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc =
          await _firestore.collection('CyberSquare').doc(user.uid).get();
      setState(() {
        _userName =
            doc['name'] ?? 'User'; // Provide a default value if 'name' is null
      });
    }
  }

  void signUserOut() {
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
            height: double.infinity,
            width: double.infinity,
            color: const Color.fromARGB(255, 239, 243, 246),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding:  EdgeInsets.only(left: 15.0, top: 15),
                        child: CircleAvatar(
                          backgroundImage: AssetImage(
                            'lib/images/personlogo.jpg',
                          ),
                          radius: 40,
                        ),
                      ),
                      IconButton(
                          onPressed: signUserOut,
                          icon: const Icon(Icons.logout_outlined))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 240.0),
                    child: Image.asset(
                      'lib/images/csquarelogo.png',
                      height: 30,
                    ),
                  ),
                 const  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Row(
                      children: [
                       const Text(
                          'Hello, ',
                          style: TextStyle(
                              color: Color.fromARGB(255, 25, 70, 153),
                              fontSize: 18),
                        ),
                        Text(
                          _userName,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 7, 60, 125),
                              fontWeight: FontWeight.bold,
                              fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      MyContainer(
                        txt: 'STUDENTS',
                        onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context)=>const StudentsPage()));},
                        width: 30,
                        child: Image.asset(
                          'lib/images/working.png',
                          height: 300,
                          width: 200,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      MyContainer(
                        txt: 'MENTORS',
                        onPressed:(){Navigator.push(context, MaterialPageRoute(builder: (context)=>const MentorsPage()));},
                        width: 30,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Image.asset(
                            'lib/images/elearning-removebg-preview.png',
                            height: 300,
                            width: 190,
                          ),
                        ),
                      ),
                     const SizedBox(
                        height: 20,
                      ),
                      MyContainer(
                        txt: 'BATCH',
                        onPressed:(){Navigator.push(context, MaterialPageRoute(builder: (context)=>const BatchPage()));},
                        width: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 40.0),
                          child: Image.asset(
                            'lib/images/team-removebg-preview.png',
                            height: 350,
                            width: 220,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      MyContainer(
                        txt: 'SCHEDULE',
                        onPressed:(){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>SchedulePage(mentors: mentors)));},
                        width: 10,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4.0),
                          child: Image.asset(
                            'lib/images/schedulee-removebg-preview.png',
                            height: 350,
                            width: 220,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      MyContainer(
                        txt: 'ATTENDANCE',
                        onPressed:(){Navigator.push(context, MaterialPageRoute(builder: (context)=>AttendancePage()));},
                        width: 12,
                        child: Image.asset(
                          'lib/images/attndnce-removebg-preview.png',
                          height: 350,
                          width: 190,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                    ],
                  )
                ],
              ),
            )),
      ),
    );
  }
}
