import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/presentation/dialogs/date_time/show_date_time_dialog.dart';
import 'package:jacht_log/presentation/extensions/event_ext.dart';

Future<Event?> showEditEventTimeDialog({
  required BuildContext context,
  required Event event,
  required DateTime minTime,
  required DateTime maxTime,
}) async {
  final newTimestamp = await showDateTimeDialog(
    context: context,
    initialValue: event.timestamp,
    firstDate: minTime,
    lastDate: maxTime,
    title: event.description(context),
    confirmLabel: 'Save',
  );

  if (newTimestamp == null) return null;

  return event.copyWith(timestamp: newTimestamp);
}
