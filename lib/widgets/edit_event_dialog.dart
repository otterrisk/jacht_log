import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/presentation/event.dart';
import 'package:jacht_log/widgets/date_time_picker.dart';

class EditEventDialog extends StatefulWidget {
  final Event event;
  final DateTime minTime;
  final DateTime maxTime;

  const EditEventDialog({
    super.key,
    required this.event,
    required this.minTime,
    required this.maxTime,
  });

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  late DateTime _timestamp;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _timestamp = widget.event.timestamp;
    _errorText = _timestamp.validate(min: widget.minTime, max: widget.maxTime);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event.description(context)),
      content: DateTimePicker(
        value: _timestamp,
        firstDate: widget.minTime,
        lastDate: widget.maxTime,
        errorText: _errorText,
        onChanged: (newTs) {
          setState(() {
            _timestamp = newTs;
            _errorText = _timestamp.validate(
              min: widget.minTime,
              max: widget.maxTime,
            );
          });
        },
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

  void _save() {
    final updated = widget.event.copyWith(timestamp: _timestamp);
    Navigator.pop(context, updated);
  }
}
