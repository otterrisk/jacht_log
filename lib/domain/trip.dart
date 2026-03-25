import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/exception.dart';
import 'package:jacht_log/domain/trip_change.dart';
import 'package:uuid/uuid.dart';

class Trip extends ChangeNotifier {
  final String id;
  final DateTime startTime;
  DateTime? endTime;
  final List<Event> events;
  final DateTime Function() _now;
  TripChange? _change;

  Trip._({
    required this.id,
    required this.startTime,
    this.endTime,
    required this.events,
    now,
  }) : _now = now ?? DateTime.now;

  factory Trip({DateTime Function()? now}) {
    return Trip._(
      id: const Uuid().v4(),
      startTime: DateTime.now(),
      endTime: null,
      events: [],
      now: now,
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

  void removeEvent(final Event event) {
    events.removeWhere((e) => e.id == event.id);
    _emit(EventRemoved(event));
  }

  bool updateEventTimestamp(String eventId, DateTime newTimestamp) {
    final index = events.indexWhere((e) => e.id == eventId);
    if (index == -1) return false;

    final oldEvent = events[index];

    _validateTimestamp(newTimestamp);

    final newEvent = oldEvent.copyWith(timestamp: newTimestamp);

    return _replaceEvent(newEvent);
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

  bool _replaceEvent(Event event) {
    final index = events.indexWhere((e) => e.id == event.id);
    if (index == -1) return false;

    events[index] = event;
    _sortEvents();
    _emit(EventUpdated(event));

    return true;
  }

  void _sortEvents() {
    events.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void _emit(TripChange change) {
    _change = change;
    notifyListeners();
  }
}
