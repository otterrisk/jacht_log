import 'package:flutter/material.dart';
import 'package:jacht_log/widgets/date_time_picker.dart';

Future<DateTime?> showDateTimePickerDialog({
  required BuildContext context,
  required DateTime value,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  DateTime temp = value;

  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            content: DateTimePicker(
              value: temp,
              firstDate: firstDate,
              lastDate: lastDate,
              onChanged: (newValue) {
                setState(() {
                  temp = newValue;
                });
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, temp),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}
