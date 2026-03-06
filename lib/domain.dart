enum EngineState { on, off }

extension EngineStateLabel on EngineState {
  String get label {
    switch (this) {
      case EngineState.on:
        return "On";
      case EngineState.off:
        return "Off";
    }
  }
}

enum EventSource { engine, sail, anchor }

enum EventType { start, stop }

class Event {
  final EventSource source;
  final EventType type;
  final DateTime timestamp;
  Event({required this.source, required this.type, required this.timestamp});
}

class Trip {
  final List<Event> events;
  Trip({required this.events});

  TripStats stats() {
    Duration motoringTime = Duration.zero;
    for (int i = 0; i < events.length - 1; i++) {
      if (events[i].type == EventType.start &&
          events[i + 1].type == EventType.stop) {
        motoringTime += events[i + 1].timestamp.difference(events[i].timestamp);
      }
    }
    return TripStats(motoringTime: motoringTime);
  }
}

class TripStats {
  final Duration motoringTime;
  TripStats({required this.motoringTime});
}
