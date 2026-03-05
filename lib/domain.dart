enum EventType { startEngine, stopEngine }

extension EventTypeLabel on EventType {
  String get label {
    switch (this) {
      case EventType.startEngine:
        return "Start engine";
      case EventType.stopEngine:
        return "Stop engine";
    }
  }
}

class Event {
  final EventType type;
  final DateTime timestamp;
  Event({required this.type, required this.timestamp});
}

class Trip {
  final DateTime start;
  final DateTime end;
  final List<Event> events;
  Trip({required this.start, required this.end, required this.events});
}

class TripStats {
  final Duration motoringTime;
  TripStats({required this.motoringTime});
}
