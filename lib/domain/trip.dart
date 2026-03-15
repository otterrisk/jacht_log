import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';

sealed class TripChange {}

class TripStarted extends TripChange {}

class TripStopped extends TripChange {}

class TripReset extends TripChange {}

class EventAdded extends TripChange {
  final Event event;
  EventAdded(this.event);
}

class Trip extends ChangeNotifier {
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  final List<Event> events = [];
  TripChange? _change;

  TripChange? get change => _change;

  bool get active => endTime == null;

  Trip();

  void _emit(TripChange change) {
    _change = change;
    notifyListeners();
  }

  void start() {
    endTime = null;
    _emit(TripStarted());
  }

  void stop() {
    endTime = DateTime.now();
    _emit(TripStopped());
  }

  void reset() {
    startTime = DateTime.now();
    endTime = null;
    events.clear();
    _emit(TripReset());
  }

  void addEvent(EventSource source, EventType type) {
    final event = Event(source: source, type: type, timestamp: DateTime.now());
    events.add(event);
    _emit(EventAdded(event));
  }

  Map<String, dynamic> toJson() => {
    'events': events.map((e) => e.toJson()).toList(),
  };

  factory Trip.fromJson(Map<String, dynamic> json) {
    final trip = Trip();

    for (var e in json['events']) {
      trip.events.add(Event.fromJson(e));
    }

    return trip;
  }
}
