import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDateWidgett extends StatelessWidget {
  const CalendarDateWidgett({super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('d \nMMMM\ny').format(DateTime.now());

    return Center(
      child: Text(
        formattedDate,
        style: const TextStyle(
            color: Color.fromARGB(255, 117, 116, 116),
            fontSize: 17,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic),
      ),
    );
  }
}
