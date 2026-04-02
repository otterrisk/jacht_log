import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final DateTime timestamp;
  final VoidCallback onTap;

  const DateField({super.key, required this.timestamp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Date'),
      subtitle: Text(
        MaterialLocalizations.of(context).formatMediumDate(timestamp),
      ),
      trailing: const Icon(Icons.calendar_today),
      onTap: onTap,
    );
  }
}
