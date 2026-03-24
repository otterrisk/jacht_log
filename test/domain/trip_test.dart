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

      test('removing event', () {
        final trip = Trip();
        final e1 = newEvent(id: '1');
        final e2 = newEvent(id: '2');
        trip.addEvent(e1);
        trip.addEvent(e2);

        trip.removeEvent(e1);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(e2));
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
        trip.startTime = DateTime(2023, 1, 1);
        final event = newEvent(timestamp: DateTime(2024, 1, 1));
        trip.addEvent(event);
        final newTime = DateTime(2025, 1, 1);

        trip.updateEventTimestamp(event.id, newTime);

        expect(trip.events.first.timestamp, equals(newTime));
      });

      test('updating does not duplicate event', () {
        final trip = Trip();
        trip.startTime = DateTime(2023, 1, 1);
        final event = newEvent();
        trip.addEvent(event);

        trip.updateEventTimestamp(event.id, DateTime(2025));

        expect(trip.events.length, 1);
      });

      test('updating event conserves event id', () {
        final trip = Trip();
        trip.startTime = DateTime(2023, 1, 1);
        final eventId = '123';
        final event = newEvent(id: eventId);
        trip.addEvent(event);

        trip.updateEventTimestamp(event.id, DateTime(2025));

        expect(trip.events.first.id, equals(eventId));
      });

      test('sorting events after timestamp update', () {
        final trip = Trip();
        trip.startTime = DateTime(2023, 1, 1);
        final older = newEvent(timestamp: DateTime(2025, 1, 1));
        final newer = newEvent(timestamp: DateTime(2026, 1, 1));
        trip.addEvent(older);
        trip.addEvent(newer);

        trip.updateEventTimestamp(newer.id, DateTime(2024, 1, 1));

        expect(trip.events.first.id, equals(newer.id));
      });

      test('updating does nothing if event not found', () {
        final trip = Trip();

        trip.updateEventTimestamp('123', DateTime(2025));

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
