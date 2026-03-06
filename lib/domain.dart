import 'package:flutter/foundation.dart';

enum Engine { on, off }

extension EngineLabel on Engine {
  String get label {
    switch (this) {
      case Engine.on:
        return "On";
      case Engine.off:
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

class Trip extends ChangeNotifier {
  final List<Event> events = [];
  Trip();

  void addEvent(EventType type) {
    events.add(
      Event(source: EventSource.engine, type: type, timestamp: DateTime.now()),
    );
    notifyListeners();
  }

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

class Boat extends ChangeNotifier {
  final Trip trip;
  Engine engine = Engine.off;

  Boat(this.trip) {
    trip.addListener(_update);
  }

  void _update() {
    for (final event in trip.events.reversed) {
      if (event.source == EventSource.engine) {
        engine = event.type == EventType.start ? Engine.on : Engine.off;
      }
      break;
    }
    notifyListeners();
  }

  void toggleEngine() {
    if (engine == Engine.on) {
      trip.addEvent(EventType.stop);
    } else {
      trip.addEvent(EventType.start);
    }
  }
}

class TripStats {
  final Duration motoringTime;
  TripStats({required this.motoringTime});
}
