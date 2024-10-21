import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  String text;
  Function()? onTap;
  MyButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 65,
        width: double.maxFinite,
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: Colors.black, 
            borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          text,
          style:const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        )),
      ),
    );
  }
}
