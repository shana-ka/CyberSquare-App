import 'package:flutter/material.dart';

class CalendarDateWidget extends StatelessWidget {
  final Function(DateTime) onDateSelected; // Accept the callback

  CalendarDateWidget({required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          onDateSelected(pickedDate); // Invoke the callback
        }
      },
      child: const Icon(
        Icons.calendar_today,
        color: Color.fromARGB(255, 86, 108, 99),
      ),
    );
  }
}
