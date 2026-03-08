import 'package:flutter/foundation.dart';

enum EventSource {
  port("Port"),
  engine("Engine"),
  sail("Sail"),
  anchor("Anchor");

  final String label;

  const EventSource(this.label);
}

enum EventType { start, stop }

class Event {
  final EventSource source;
  final EventType type;
  final DateTime timestamp;
  Event({required this.source, required this.type, required this.timestamp});
}

class Trip extends ChangeNotifier {
  final List<Event> events = [];

  Trip() {
    addEvent(EventSource.port, EventType.start);
  }

  void addEvent(EventSource source, EventType type) {
    events.add(Event(source: source, type: type, timestamp: DateTime.now()));
    notifyListeners();
  }
}
