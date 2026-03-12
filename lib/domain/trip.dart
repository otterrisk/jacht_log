import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';

class Trip extends ChangeNotifier {
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  final List<Event> events = [];

  Trip();

  bool get active => endTime == null;

  void start() {
    endTime = null;
    events.clear();
    notifyListeners();
  }

  void stop() {
    endTime = DateTime.now();
    notifyListeners();
  }

  void addEvent(EventSource source, EventType type) {
    events.add(Event(source: source, type: type, timestamp: DateTime.now()));
    notifyListeners();
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
