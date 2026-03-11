import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:jacht_log/event.dart';
import 'package:path_provider/path_provider.dart';

class Trip extends ChangeNotifier {
  DateTime startTime = DateTime.now();
  DateTime? endTime;
  final List<Event> events = [];

  Trip();

  bool get active => endTime == null;

  void start() {
    endTime = null;
    events.clear();
    addEvent(EventSource.port, EventType.start);
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
