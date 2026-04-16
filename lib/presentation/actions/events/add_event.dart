import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/dialogs/events/show_add_event_dialog.dart';

Future<void> addEvent({
  required BuildContext context,
  required Trip trip,
}) async {
  final result = await showAddEventDialog(
    context: context,
    minTime: trip.requireStartTime(),
    maxTime: trip.effectiveEndTime,
  );

  if (result == null) return;

  trip.addEvent(
    Event(
      source: result.source,
      type: result.type,
      timestamp: result.timestamp,
    ),
  );
}
