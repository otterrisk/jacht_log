import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/presentation/event.dart';

class EventPreset {
  final EventSource source;
  final EventType type;

  const EventPreset(this.source, this.type);
}

const eventPresets = [
  EventPreset(EventSource.port, EventType.start),
  EventPreset(EventSource.port, EventType.stop),
  EventPreset(EventSource.anchor, EventType.start),
  EventPreset(EventSource.anchor, EventType.stop),
  EventPreset(EventSource.engine, EventType.start),
  EventPreset(EventSource.engine, EventType.stop),
  EventPreset(EventSource.sail, EventType.start),
  EventPreset(EventSource.sail, EventType.stop),
];

extension EventPresetDescription on EventPreset {
  String description(BuildContext context) {
    return eventDescription(context, source, type);
  }
}
