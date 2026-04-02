import 'package:flutter/material.dart';
import 'package:jacht_log/widgets/date_picker.dart';
import 'package:jacht_log/widgets/time_picker.dart';

class DateTimePicker extends StatelessWidget {
  final DateTime value;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;
  final String? errorText;

  const DateTimePicker({
    super.key,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DatePicker(
          timestamp: value,
          firstDate: firstDate,
          lastDate: lastDate,
          onChanged: onChanged,
        ),
        TimePicker(timestamp: value, onChanged: onChanged),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

extension DateTimeValidation on DateTime {
  String? validate({required DateTime min, required DateTime max}) {
    if (isBefore(min)) return 'Date/time is before trip start';
    if (isAfter(max)) return 'Date/time is after trip end';
    return null;
  }
}
