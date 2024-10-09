import 'package:flutter/material.dart';

class MyContainer extends StatelessWidget {
  String txt;
  Widget child;
  double? width;
  VoidCallback? onPressed;
  MyContainer(
      {super.key,
      required this.txt,
      required this.child,
      this.width,
       this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
          height: 140,
          width: 360,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color.fromARGB(255, 226, 232, 241),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 5, // How far the shadow extends
                blurRadius: 7, // How blurry the shadow is
                offset: Offset(0, 3), // Changes position of shadow
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      txt,
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 2, 42, 92)),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
              SizedBox(
                width: width,
              ),
              child,
            ],
          )),
    );
  }
}
