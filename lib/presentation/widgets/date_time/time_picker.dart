import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  final DateTime timestamp;
  final ValueChanged<DateTime> onChanged;

  const TimePicker({
    super.key,
    required this.timestamp,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);

    return ListTile(
      key: const Key('timePicker'),
      contentPadding: EdgeInsets.zero,
      title: const Text('Time'),
      subtitle: Text(
        localizations.formatTimeOfDay(TimeOfDay.fromDateTime(timestamp)),
      ),
      trailing: const Icon(Icons.access_time),
      onTap: () => _pickTime(context),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(timestamp),
    );

    if (time == null) return;

    final newTimestamp = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
      time.hour,
      time.minute,
    );

    onChanged(newTimestamp);
  }
}
