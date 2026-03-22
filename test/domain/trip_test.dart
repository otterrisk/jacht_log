import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';

Event newEvent({
  String id = '123',
  EventSource source = EventSource.port,
  EventType type = EventType.start,
  DateTime? timestamp,
}) {
  final ts = timestamp ?? DateTime(2024, 1, 1);
  final json = {
    'id': id,
    'source': source.name,
    'type': type.name,
    'timestamp': ts.toIso8601String(),
  };
  return Event.fromJson(json);
}

void main() {
  group('Trip', () {
    group('Event management', () {
      test('adding event', () {
        final trip = Trip();
        final event = newEvent();

        trip.addEvent(event);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(event));
      });

      test('sorting events by timestamp after adding', () {
        final trip = Trip();
        final older = newEvent(id: '2', timestamp: DateTime(2024, 1, 1));
        final newer = newEvent(id: '1', timestamp: DateTime(2025, 1, 1));

        trip.addEvent(newer);
        trip.addEvent(older);

        expect(trip.events.first, equals(older));
        expect(trip.events.last, equals(newer));
      });

      test('updating event timestamp', () {
        final trip = Trip();
        final original = newEvent(timestamp: DateTime(2024, 1, 1));
        trip.addEvent(original);
        final newTime = DateTime(2025, 1, 1);
        final updated = original.copyWith(timestamp: newTime);

        trip.updateEvent(updated);

        expect(trip.events.first.timestamp, equals(newTime));
      });

      test('updating does not duplicate event', () {
        final trip = Trip();
        final event = newEvent();
        trip.addEvent(event);

        final updated = event.copyWith(timestamp: DateTime(2025));
        trip.updateEvent(updated);

        expect(trip.events.length, 1);
      });

      test('updating event conserves event id', () {
        final trip = Trip();
        final event = newEvent();
        trip.addEvent(event);

        final updated = event.copyWith(timestamp: DateTime(2025));
        trip.updateEvent(updated);

        expect(trip.events.first.id, equals(event.id));
      });

      test('removeEvent removes correct event', () {
        final trip = Trip();
        final e1 = newEvent(id: '1');
        final e2 = newEvent(id: '2');
        trip.addEvent(e1);
        trip.addEvent(e2);

        trip.removeEvent(e1);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(e2));
      });

      test('sorting events after timestamp update', () {
        final trip = Trip();
        final older = newEvent(timestamp: DateTime(2024, 1, 1));
        final newer = newEvent(timestamp: DateTime(2025, 1, 1));
        trip.addEvent(older);
        trip.addEvent(newer);

        final updated = newer.copyWith(timestamp: DateTime(2023, 1, 1));
        trip.updateEvent(updated);

        expect(trip.events.first.id, equals(newer.id));
      });

      test('updating does nothing if event not found', () {
        final trip = Trip();

        final event = newEvent();
        trip.updateEvent(event);

        expect(trip.events, isEmpty);
      });
    });

    group('serialization', () {
      test('Trip serialization/deserialization conserves all fields', () {
        final original = Trip();
        final event = newEvent();
        original.addEvent(event);

        final restored = Trip.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.startTime, original.startTime);
        expect(restored.endTime, original.endTime);
        expect(restored.events.length, 1);
        expect(restored.events.first, equals(event));
      });
    });
  });
}
