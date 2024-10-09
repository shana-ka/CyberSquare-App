import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cybersquareapp/components/my_button.dart';
import 'package:cybersquareapp/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  Function() onTap;
  RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final firestore=FirebaseFirestore.instance;
    final auth=FirebaseAuth.instance;

  void signUserUp() async {
try {
  if (passwordController.text == confirmpasswordController.text) {
    // Attempt to create a user with email and password
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    );

    // If user creation is successful, add the user details to Firestore
    await firestore.collection('CyberSquare').doc(userCredential.user!.uid).set({
      'name': usernameController.text,
      'email': emailController.text,
    });

    // Navigate back after successful registration
    // Navigator.pop(context);
  } else {
    showError("Passwords don't match!");
  }
} on FirebaseAuthException catch (e) {
  // Handle Firebase-specific errors
  showError(e.message ?? "An error occurred");
} catch (e) {
  // Handle any other type of error
  showError("An unexpected error occurred: ${e.toString()}");
  Navigator.pop(context);
}


  }

  void showError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  height: 100,
                ),
                Image.asset(
                  'lib/images/bluuuueee-removebg-preview.png',
                  height: 100,
                ),
                Image.asset(
                  'lib/images/csquarelogo.png',
                  height: 65,
                ),
                SizedBox(
                  height: 60,
                ),
                // username textfield
                 MyTextfield(
                    icon: Icon(Icons.person_3_outlined),
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false),
                SizedBox(
                  height: 15,
                ),
                // email textfield
                MyTextfield(
                    icon: Icon(Icons.email_outlined),
                    controller: emailController,
                    hintText: 'E-mail',
                    obscureText: false),
                SizedBox(
                  height: 15,
                ),
                // passwprd textfield
                MyTextfield(
                    icon: Icon(Icons.lock_outlined),
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true),
                SizedBox(
                  height: 15,
                ),
                // confirm password
                MyTextfield(
                    icon: Icon(Icons.lock_outlined),
                    controller: confirmpasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true),
                SizedBox(
                  height: 10,
                ),
                // forgot password

                SizedBox(
                  height: 50,
                ),
                // login button
                MyButton(
                  text: 'Register Here',
                  onTap: signUserUp,
                ),
                SizedBox(
                  height: 12,
                ),
                // Already have an account? then Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      ' Already have an account?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        'Login now',
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
