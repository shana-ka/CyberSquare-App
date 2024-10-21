// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class CalendarDateWidgett extends StatelessWidget {
//   const CalendarDateWidgett({super.key});

//   @override
//   Widget build(BuildContext context) {
//     String formattedDate = DateFormat('d \nMMMM\ny').format(DateTime.now());

//     return Center(
//       child: Text(
//         formattedDate,
//         style: const TextStyle(
//             color: Color.fromARGB(255, 117, 116, 116),
//             fontSize: 17,
//             fontWeight: FontWeight.w600,
//             fontStyle: FontStyle.italic),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarDateWidget extends StatefulWidget {
  final DateTime? initialDate;
  final void Function(DateTime) onDateSelected;

  const CalendarDateWidget({
    Key? key,
    required this.onDateSelected,
    this.initialDate,
  }) : super(key: key);

  @override
  _CalendarDateWidgetState createState() => _CalendarDateWidgetState();
}

class _CalendarDateWidgetState extends State<CalendarDateWidget> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        widget.onDateSelected(_selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(DateFormat.yMMMd().format(_selectedDate!)),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _selectDate(context),
        ),
      ],
    );
  }
}

