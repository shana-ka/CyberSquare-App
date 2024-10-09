import 'package:cybersquareapp/components/my_button.dart';
import 'package:cybersquareapp/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
Function() onTap;
  LoginPage({super.key,required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController=TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn() async {
     if (emailController.text.isEmpty || passwordController.text.isEmpty) {
    showError('Please enter both email and password');
    return;
  }
    // loading circle
    showDialog(
        context: context,
        builder: (context) {
          return Center(child: CircularProgressIndicator());
        });
    // login
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
       
          email: emailController.text,
          password: passwordController.text,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showError(e.code);
    }
  }

  void showError(String message){
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
                    controller: emailController,
                    hintText: 'E-mail',
                    obscureText: false),
                SizedBox(
                  height: 15,
                ),
                // passwprd textfield
                MyTextfield(
                    icon: Icon(Icons.password_outlined),
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true),
                // SizedBox(
                //   height: 10,
                // ),
                // forgot password
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 25.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Text('forgot password?',
                //           style:
                //               TextStyle(color: Colors.grey[600], fontSize: 13))
                //     ],
                //   ),
                // ),
                SizedBox(
                  height: 50,
                ),
                // login button
                MyButton(
                  text: 'Login',
                  onTap: signUserIn,
                ),
                SizedBox(
                  height: 12,
                ),
                // Dont have an account? Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap:widget.onTap,
                      child: Text(
                        'Register now',
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
