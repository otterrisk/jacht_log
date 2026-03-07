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

enum Mode {
  sailing("Sailing"),
  motoring("Motoring"),
  parking("Parking");

  final String label;

  const Mode(this.label);
}

class Boat extends ChangeNotifier {
  final trip = Trip();
  final Map<EventSource, bool> state = {};
  final List<Duration> time = List.filled(Mode.values.length, Duration.zero);
  DateTime? lastTime;

  Boat() {
    trip.addListener(_update);
    _rebuild();
  }

  void _update() {
    final event = trip.events.last;
    updateTime(event);
    updateState(event);
    notifyListeners();
  }

  void updateTime(Event event) {
    if (lastTime != null) {
      time[mode.index] += event.timestamp.difference(lastTime!);
    }
    lastTime = event.timestamp;
  }

  void updateState(final Event event) {
    state[event.source] = event.type == EventType.start;
  }

  void _rebuild() {
    for (final event in trip.events) {
      updateState(event);
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

  Mode get mode {
    if (isOn(EventSource.port) || isOn(EventSource.anchor)) {
      return Mode.parking;
    }

    if (isOn(EventSource.sail)) {
      return Mode.sailing;
    }

    if (isOn(EventSource.engine)) {
      return Mode.motoring;
    }

    return Mode.sailing; // TODO consider adding TripMode.afloat
  }
}
