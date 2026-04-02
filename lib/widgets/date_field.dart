import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final DateTime timestamp;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const DateField({
    super.key,
    required this.timestamp,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Date'),
      subtitle: Text(
        MaterialLocalizations.of(context).formatMediumDate(timestamp),
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: () => _pickDate(context),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: timestamp,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date == null) return;

    final newTimestamp = DateTime(
      date.year,
      date.month,
      date.day,
      timestamp.hour,
      timestamp.minute,
    );

    onChanged(newTimestamp);
  }
}
