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
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _timestamp = widget.event.timestamp;
    _validate(_timestamp);
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

    setState(() {
      _timestamp = newTimestamp;
      _validate(newTimestamp);
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

    setState(() {
      _timestamp = newTimestamp;
      _validate(newTimestamp);
    });
  }

  void _validate(DateTime ts) {
    if (ts.isBefore(widget.minTime)) {
      _errorText = 'Date/time is before trip start';
    } else if (ts.isAfter(widget.maxTime)) {
      _errorText = 'Date/time is after trip end';
    } else {
      _errorText = null;
    }
  }

  void _save() {
    final updated = widget.event.copyWith(timestamp: _timestamp);
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event.description(context)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DateField(timestamp: _timestamp, onTap: _pickDate),
          _TimeField(timestamp: _timestamp, onTap: _pickTime),

          if (_errorText != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _errorText == null ? _save : null,
          child: const Text('Save'),
        ),
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
