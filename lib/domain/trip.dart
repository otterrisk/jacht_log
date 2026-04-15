import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/exception.dart';
import 'package:jacht_log/domain/trip_change.dart';
import 'package:uuid/uuid.dart';

class Trip extends ChangeNotifier {
  final String id;
  DateTime? startTime;
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
      startTime: null,
      endTime: null,
      events: <Event>[],
      now: now,
    );
  }

  factory Trip.fromJson(Map<String, dynamic> json) {
    final trip = Trip._(
      id: json['id'],
      startTime: json['startTime'] == null
          ? null
          : DateTime.parse(json['startTime']),
      endTime: json['endTime'] == null ? null : DateTime.parse(json['endTime']),
      events: (json['events'] as List).map((e) => Event.fromJson(e)).toList(),
    );
    trip._validateStartEnd();
    trip._validateEvents();
    trip._sortEvents();
    return trip;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'events': events.map((e) => e.toJson()).toList(),
  };

  List<Event> get events => List.unmodifiable(_events);

  TripChange? get change => _change;

  bool get started => startTime != null;

  bool get finished => endTime != null;

  bool get active => started && !finished;

  bool get canAddEvent => started;

  DateTime requireStartTime() {
    final value = startTime;
    if (value == null) {
      throw DomainException(DomainError.tripNotStarted);
    }
    return value;
  }

  DateTime get effectiveEndTime => endTime ?? _now();

  void start() {
    if (started) throw DomainException(DomainError.tripAlreadyStarted);
    startTime = _now();
    endTime = null;
    _emit(TripStarted());
  }

  void stop() {
    if (!active) throw DomainException(DomainError.tripNotActive);
    endTime = _now();
    _emit(TripStopped());
  }

  void addEvent(Event event) {
    if (!canAddEvent) throw DomainException(DomainError.tripNotStarted);
    _validateTimestamp(event.timestamp);
    _events.add(event);
    _sortEvents();
    _emit(EventAdded(event));
  }

  void removeEvent(String eventId) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) throw DomainException(DomainError.eventNotFound);

    final removed = _events.removeAt(index);
    _emit(EventRemoved(removed));
  }

  void updateEventTimestamp(String eventId, DateTime newTimestamp) {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index == -1) throw DomainException(DomainError.eventNotFound);

    _validateTimestamp(newTimestamp);

    final updated = _events[index].copyWith(timestamp: newTimestamp);
    _events[index] = updated;

    _sortEvents();
    _emit(EventUpdated(updated));
  }

  void _validateStartEnd() {
    if (!started) return;

    final start = startTime!;
    final end = effectiveEndTime;
    if (end.isBefore(start)) {
      throw DomainException(
        finished
            ? DomainError.tripEndBeforeTripStart
            : DomainError.tripStartInFuture,
      );
    }
  }

  void _validateEvents() {
    for (final event in _events) {
      _validateTimestamp(event.timestamp);
    }
  }

  void _validateTimestamp(DateTime timestamp) {
    if (!started) {
      throw DomainException(DomainError.tripNotStarted);
    }

    final start = startTime!;
    if (timestamp.isBefore(start)) {
      throw DomainException(DomainError.eventBeforeTripStart);
    }

    if (finished) {
      final end = endTime!;
      if (timestamp.isAfter(end)) {
        throw DomainException(DomainError.eventAfterTripEnd);
      }
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
