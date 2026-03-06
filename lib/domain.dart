import 'package:flutter/foundation.dart';

enum Engine { on, off }

enum Sail { up, down }

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
  var sailingTime = Duration.zero;
  var motoringTime = Duration.zero;

  Trip();

  void addEvent(EventSource source, EventType type) {
    events.add(Event(source: source, type: type, timestamp: DateTime.now()));
    _update();
    notifyListeners();
  }

  void _update() {
    sailingTime = calculateDuration(EventSource.sail);
    motoringTime = calculateDuration(EventSource.engine);
  }

  Duration calculateDuration(EventSource source) {
    DateTime? startTime;
    Duration total = Duration.zero;

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
  Sail sail = Sail.down;
  Engine engine = Engine.off;

  Boat(this.trip) {
    trip.addListener(_update);
  }

  void _update() {
    _updateSail();
    _updateEngine();
    notifyListeners();
  }

  void _updateSail() {
    for (final event in trip.events.reversed) {
      if (event.source == EventSource.sail) {
        sail = event.type == EventType.start ? Sail.up : Sail.down;
      }
      break;
    }
  }

  void _updateEngine() {
    for (final event in trip.events.reversed) {
      if (event.source == EventSource.engine) {
        engine = event.type == EventType.start ? Engine.on : Engine.off;
      }
      break;
    }
  }

  void toggleSail() {
    if (sail == Sail.up) {
      trip.addEvent(EventSource.sail, EventType.stop);
    } else {
      trip.addEvent(EventSource.sail, EventType.start);
    }
  }

  void toggleEngine() {
    if (engine == Engine.on) {
      trip.addEvent(EventSource.engine, EventType.stop);
    } else {
      trip.addEvent(EventSource.engine, EventType.start);
    }
  }
}
