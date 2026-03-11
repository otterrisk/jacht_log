import 'package:jacht_log/event.dart';

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
