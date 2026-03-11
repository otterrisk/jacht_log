import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/foundation.dart';

enum EventSource { port, engine, sail, anchor }

enum EventType { start, stop }

class Event {
  final EventSource source;
  final EventType type;
  final DateTime timestamp;
  Event({required this.source, required this.type, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'source': source.name,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      source: EventSource.values.byName(json['source']),
      type: EventType.values.byName(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class Trip extends ChangeNotifier {
  bool active = false;
  final List<Event> events = [];

  Trip();

  void start() {
    active = true;
    events.clear();
    notifyListeners();
  }

  void stop() {
    active = false;
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

class TripStorage {
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/trip.json');
  }

  Future<void> save(Trip trip) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(trip.toJson()));
  }

  Future<Trip> load() async {
    try {
      final file = await _getFile();

      if (!await file.exists()) {
        return Trip();
      }

      final json = jsonDecode(await file.readAsString());
      return Trip.fromJson(json);
    } catch (e) {
      return Trip();
    }
  }
}
