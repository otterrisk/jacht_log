import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/exception.dart';
import 'package:jacht_log/domain/trip_change.dart';
import 'package:uuid/uuid.dart';

class Trip extends ChangeNotifier {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<Event> _events;
  final DateTime Function() _now;
  TripChange? _change;

  Trip._({
    required this.id,
    required this.startTime,
    this.endTime,
    required List<Event> events,
    now,
  }) : _events = List.of(events),
       _now = now ?? DateTime.now;

  factory Trip({DateTime Function()? now}) {
    now ??= DateTime.now;
    return Trip._(
      id: const Uuid().v4(),
      startTime: now(),
      endTime: null,
      events: <Event>[],
      now: now,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    final trip = Trip._(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] == null ? null : DateTime.parse(json['endTime']),
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
    );
    trip._validateEvents();
    trip._sortEvents();
    return trip;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'events': events.map((e) => e.toJson()).toList(),
  };

  List<Event> get events => List.unmodifiable(_events);

  TripChange? get change => _change;

  bool get active => endTime == null;

  void start() {
    endTime = null;
    _emit(TripStarted());
  }

  void stop() {
    endTime = _now();
    _emit(TripStopped());
  }

  void addEvent(final Event event) {
    _validateTimestamp(event.timestamp);
    _events.add(event);
    _sortEvents();
    _emit(EventAdded(event));
  }

  void removeEvent(Event event) {
    _events.removeWhere((e) => e.id == event.id);
    _emit(EventRemoved(event));
  }

  bool updateEventTimestamp(String eventId, DateTime newTimestamp) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;

    _validateTimestamp(newTimestamp);

    final event = _events[index].copyWith(timestamp: newTimestamp);
    _events[index] = event;

    _sortEvents();
    _emit(EventUpdated(event));

    return true;
  }

  void _validateEvents() {
    for (final event in _events) {
      _validateTimestamp(event.timestamp);
    }
  }

  void _validateTimestamp(DateTime timestamp) {
    if (timestamp.isBefore(startTime)) {
      throw DomainException(DomainError.eventBeforeTripStart);
    }

    final upperBound = endTime ?? _now();

    if (timestamp.isAfter(upperBound)) {
      throw DomainException(
        endTime == null
            ? DomainError.eventInFuture
            : DomainError.eventAfterTripEnd,
      );
    }
  }

  void _sortEvents() {
    _events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _emit(TripChange change) {
    _change = change;
    notifyListeners();
  }
}
