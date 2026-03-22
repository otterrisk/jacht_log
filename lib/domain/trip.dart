import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:uuid/uuid.dart';

sealed class TripChange {}

class TripStarted extends TripChange {}

class TripStopped extends TripChange {}

class EventAdded extends TripChange {
  final Event event;
  EventAdded(this.event);
}

class EventUpdated extends TripChange {
  final Event event;
  EventUpdated(this.event);
}

class Trip extends ChangeNotifier {
  final String id;
  DateTime startTime;
  DateTime? endTime;
  final List<Event> events;
  TripChange? _change;

  Trip._({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.events,
  });

  factory Trip() {
    return Trip._(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      endTime: null,
      events: [],
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip._(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] == null ? null : DateTime.parse(json['endTime']),
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'events': events.map((e) => e.toJson()).toList(),
  };

  TripChange? get change => _change;

  bool get active => endTime == null;

  void start() {
    endTime = null;
    _emit(TripStarted());
  }

  void stop() {
    endTime = DateTime.now();
    _emit(TripStopped());
  }

  void addEvent(final Event event) {
    events.add(event);
    _sortEvents();
    _emit(EventAdded(event));
  }

  void updateEvent(final Event event) {
    final index = events.indexWhere((e) => e.id == event.id);

    if (index != -1) {
      events[index] = event;
      _sortEvents();
      _emit(EventUpdated(event));
    }
  }

  void _sortEvents() {
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _emit(TripChange change) {
    _change = change;
    notifyListeners();
  }
}

  // factory Trip.create({required DateTime startTime}) {
  //   return Trip._(
  //     id: const Uuid().v4(),
  //     startTime: startTime,
  //     endTime: null,
  //     events: [],
  //   );
  // }

  // factory Trip.restore({
  //   required String id,
  //   required DateTime startTime,
  //   DateTime? endTime,
  //   required List<Event> events,
  // }) {
  //   final trip = Trip._(
  //     id: id,
  //     startTime: startTime,
  //     endTime: endTime,
  //     events: List.of(events),
  //   );

  //   trip._validateInvariants();
  //   trip._sortEvents();

  //   return trip;
  // }
