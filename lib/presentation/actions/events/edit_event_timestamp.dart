import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/dialogs/events/show_edit_event_time_dialog.dart';

Future<void> editEventTimestamp({
  required BuildContext context,
  required Event event,
  required Trip trip,
}) async {
  final updated = await showEditEventTimeDialog(
    context: context,
    event: event,
    minTime: trip.requireStartTime(),
    maxTime: trip.effectiveEndTime,
  );

  if (updated == null) return;

  trip.updateEventTimestamp(updated.id, updated.timestamp);
}
