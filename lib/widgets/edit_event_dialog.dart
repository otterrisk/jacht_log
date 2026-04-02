import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/presentation/event.dart';
import 'package:jacht_log/widgets/date_field.dart';
import 'package:jacht_log/widgets/time_field.dart';

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
    _validate(_timestamp);
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
          DateField(
            timestamp: _timestamp,
            firstDate: widget.minTime,
            lastDate: widget.maxTime,
            onChanged: (newTs) {
              setState(() {
                _timestamp = newTs;
                _validate(newTs);
              });
            },
          ),
          TimeField(
            timestamp: _timestamp,
            onChanged: (newTs) {
              setState(() {
                _timestamp = newTs;
                _validate(newTs);
              });
            },
          ),

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
