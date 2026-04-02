import 'package:flutter/material.dart';

class TimeField extends StatelessWidget {
  final DateTime timestamp;
  final VoidCallback onTap;

  const TimeField({super.key, required this.timestamp, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Time'),
      subtitle: Text(
        MaterialLocalizations.of(
          context,
        ).formatTimeOfDay(TimeOfDay.fromDateTime(timestamp)),
      ),
      trailing: const Icon(Icons.access_time),
      onTap: onTap,
    );
  }
}
