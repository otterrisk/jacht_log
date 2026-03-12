import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';

extension EventSourceLabel on EventSource {
  String get label {
    switch (this) {
      case EventSource.port:
        return "Port";
      case EventSource.anchor:
        return "Anchor";
      case EventSource.engine:
        return "Engine";
      case EventSource.sail:
        return "Sail";
    }
  }
}

extension EventSourceIcon on EventSource {
  IconData get icon {
    switch (this) {
      case EventSource.engine:
        return Icons.settings;
      case EventSource.sail:
        return Icons.sailing;
      case EventSource.port:
        return Icons.directions_boat;
      case EventSource.anchor:
        return Icons.anchor;
    }
  }
}

const Map<(EventSource, EventType), String> eventDescriptions = {
  (EventSource.port, EventType.start): "Moored",
  (EventSource.port, EventType.stop): "Cast off",

  (EventSource.anchor, EventType.start): "Anchor casted",
  (EventSource.anchor, EventType.stop): "Anchor weighed",

  (EventSource.engine, EventType.start): "Engine started",
  (EventSource.engine, EventType.stop): "Engine stopped",

  (EventSource.sail, EventType.start): "Sail hoisted",
  (EventSource.sail, EventType.stop): "Sail lowered",
};

extension EventDescription on Event {
  String get description => eventDescriptions[(source, type)]!;
}
