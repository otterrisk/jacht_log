import 'package:flutter/foundation.dart';

enum EventSource { port, engine, sail, anchor }

extension EventSourceExtension on EventSource {
  String get name {
    switch (this) {
      case EventSource.port:
        return 'Port';
      case EventSource.engine:
        return 'Engine';
      case EventSource.sail:
        return 'Sail';
      case EventSource.anchor:
        return 'Anchor';
    }
  }
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
  final Map<EventSource, Duration> time = {};

  Trip() {
    _update();
  }

  void addEvent(EventSource source, EventType type) {
    events.add(Event(source: source, type: type, timestamp: DateTime.now()));
    _update();
  }

  void _update() {
    for (final source in EventSource.values) {
      time[source] = calculateDuration(source);
    }
    notifyListeners();
  }

  Duration calculateDuration(EventSource source) {
    DateTime? startTime;
    var total = Duration.zero;

    for (final event in events) {
      if (event.source != source) continue;

      if (event.type == EventType.start) {
        startTime = event.timestamp;
      }

      if (event.type == EventType.stop && startTime != null) {
        total += event.timestamp.difference(startTime);
        startTime = null;
      }
    }

    return total;
  }
}

class Boat extends ChangeNotifier {
  final Trip trip;
  final Map<EventSource, bool> state = {};

  Boat(this.trip) {
    trip.addListener(_update);
    _rebuild();
  }

  void _update() {
    final event = trip.events.last;
    state[event.source] = event.type == EventType.start;
    notifyListeners();
  }

  void _rebuild() {
    for (final event in trip.events) {
      state[event.source] = event.type == EventType.start;
    }
  }

  bool isOn(EventSource source) => state[source] == true;

  void toggle(EventSource source) {
    if (state[source] == true) {
      trip.addEvent(source, EventType.stop);
    } else {
      trip.addEvent(source, EventType.start);
    }
  }
}
