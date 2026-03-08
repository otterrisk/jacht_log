import 'package:hello/event.dart';

const Map<(EventSource, EventType), String> eventDescriptions = {
  (EventSource.sail, EventType.start): "Sail hoisted",
  (EventSource.sail, EventType.stop): "Sail lowered",

  (EventSource.engine, EventType.start): "Engine started",
  (EventSource.engine, EventType.stop): "Engine stopped",

  (EventSource.port, EventType.start): "Moored",
  (EventSource.port, EventType.stop): "Cast off",

  (EventSource.anchor, EventType.start): "Anchor casted",
  (EventSource.anchor, EventType.stop): "Anchor weighed",
};

extension EventDescription on Event {
  String get description => eventDescriptions[(source, type)]!;
}
