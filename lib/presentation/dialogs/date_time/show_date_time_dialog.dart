import 'package:flutter/material.dart';
import 'package:jacht_log/presentation/widgets/date_time/date_time_dialog.dart';

Future<DateTime?> showDateTimeDialog({
  required BuildContext context,
  required DateTime initialValue,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
  String confirmLabel = 'OK',
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (context) {
      return DateTimeDialog(
        initialValue: initialValue,
        firstDate: firstDate,
        lastDate: lastDate,
        title: title,
        confirmLabel: confirmLabel,
      );
    },
  );
}
