import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/presentation/event.dart';

class EventEditorDialog extends StatefulWidget {
  final Event event;
  final DateTime minTime;
  final DateTime maxTime;

  const EventEditorDialog({
    super.key,
    required this.event,
    required this.minTime,
    required this.maxTime,
  });

  @override
  State<EventEditorDialog> createState() => _EventEditorDialogState();
}

class _EventEditorDialogState extends State<EventEditorDialog> {
  late DateTime _timestamp;

  @override
  void initState() {
    super.initState();
    _timestamp = widget.event.timestamp;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _timestamp,
      firstDate: widget.minTime,
      lastDate: widget.maxTime,
    );

    if (date == null) return;

    final newTimestamp = DateTime(
      date.year,
      date.month,
      date.day,
      _timestamp.hour,
      _timestamp.minute,
    );

    if (!_isValid(newTimestamp)) {
      _showError();
      return;
    }

    setState(() {
      _timestamp = newTimestamp;
    });
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_timestamp),
    );

    if (time == null) return;

    final newTimestamp = DateTime(
      _timestamp.year,
      _timestamp.month,
      _timestamp.day,
      time.hour,
      time.minute,
    );

    if (!_isValid(newTimestamp)) {
      _showError();
      return;
    }

    setState(() {
      _timestamp = newTimestamp;
    });
  }

  bool _isValid(DateTime ts) {
    return !ts.isBefore(widget.minTime) && !ts.isAfter(widget.maxTime);
  }

  void _save() {
    if (!_isValid(_timestamp)) {
      _showError();
      return;
    }

    final updated = widget.event.copyWith(timestamp: _timestamp);

    Navigator.pop(context, updated);
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Date and time must be within trip range.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event.description(context)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DateField(timestamp: _timestamp, onTap: _pickDate),
          _TimeField(timestamp: _timestamp, onTap: _pickTime),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime timestamp;
  final VoidCallback onTap;

  const _DateField({required this.timestamp, required this.onTap});

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

class _TimeField extends StatelessWidget {
  final DateTime timestamp;
  final VoidCallback onTap;

  const _TimeField({required this.timestamp, required this.onTap});

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
