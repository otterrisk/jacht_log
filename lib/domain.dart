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

enum TripMode { parking, sailing, motoring }

class ModeChange {
  final DateTime time;
  final TripMode mode;

  ModeChange(this.time, this.mode);
}

class Boat extends ChangeNotifier {
  final Trip trip;
  final Map<EventSource, bool> state = {};
  final List<ModeChange> changes = [];

  Boat(this.trip) {
    trip.addListener(_update);
    _rebuild();
  }

  void _update() {
    final event = trip.events.last;
    final oldMode = tripMode;
    updateState(event);
    final newMode = tripMode;
    if (oldMode != newMode) {
      changes.add(ModeChange(event.timestamp, newMode));
    }
    notifyListeners();
  }

  void updateState(final Event event) {
    state[event.source] = event.type == EventType.start;
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

  TripMode get tripMode {
    if (isOn(EventSource.port) || isOn(EventSource.anchor)) {
      return TripMode.parking;
    }

    if (isOn(EventSource.sail)) {
      return TripMode.sailing;
    }

    if (isOn(EventSource.engine)) {
      return TripMode.motoring;
    }

    return TripMode.sailing; // TODO consider adding TripMode.afloat
  }
}
