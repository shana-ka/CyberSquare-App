import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyTextfield extends StatelessWidget {
  final controller;
  Widget icon;
  final String hintText;
  final bool obscureText;
   MyTextfield({super.key,required this.icon,required this.controller,
  required this.hintText,required this.obscureText});

  @override
  Widget build(BuildContext context) {
    return  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: TextField(
                 
                  controller: controller,
                  obscureText: obscureText,
                  decoration: InputDecoration(
                      prefixIcon: icon,
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400)),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: hintText,
                      hintStyle: TextStyle(color: Colors.grey[500])
                      ),
                ),
              );
  }
}