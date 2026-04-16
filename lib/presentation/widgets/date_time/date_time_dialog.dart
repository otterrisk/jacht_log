import 'package:flutter/material.dart';
import 'package:jacht_log/widgets/date_time_picker.dart';

class DateTimeDialog extends StatefulWidget {
  final DateTime initialValue;
  final DateTime firstDate;
  final DateTime lastDate;
  final String? title;
  final String confirmLabel;

  const DateTimeDialog({
    super.key,
    required this.initialValue,
    required this.firstDate,
    required this.lastDate,
    this.title,
    this.confirmLabel = 'OK',
  });

  @override
  State<DateTimeDialog> createState() => _DateTimeDialogState();
}

class _DateTimeDialogState extends State<DateTimeDialog> {
  late DateTime _value;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _validate();
  }

  void _validate() {
    setState(() {
      _errorText = _value.validate(min: widget.firstDate, max: widget.lastDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title != null ? Text(widget.title!) : null,
      content: DateTimePicker(
        value: _value,
        firstDate: widget.firstDate,
        lastDate: widget.lastDate,
        errorText: _errorText,
        onChanged: (newValue) {
          _value = newValue;
          _validate();
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _errorText == null
              ? () => Navigator.pop(context, _value)
              : null,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
