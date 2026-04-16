import 'package:flutter/material.dart';
import 'package:jacht_log/presentation/dto/event_result.dart';
import 'package:jacht_log/widgets/add_event_dialog.dart';

Future<EventResult?> showAddEventDialog({
  required BuildContext context,
  required DateTime minTime,
  required DateTime maxTime,
}) {
  return showDialog<EventResult>(
    context: context,
    builder: (_) => AddEventDialog(minTime: minTime, maxTime: maxTime),
  );
}
