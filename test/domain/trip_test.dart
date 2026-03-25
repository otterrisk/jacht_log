import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';

Event newEvent({
  String id = '123',
  EventSource source = EventSource.port,
  EventType type = EventType.start,
  DateTime? timestamp,
}) {
  final ts = timestamp ?? DateTime(2024, 7, 5);
  final json = {
    'id': id,
    'source': source.name,
    'type': type.name,
    'timestamp': ts.toIso8601String(),
  };
  return Event.fromJson(json);
}

Trip newTrip({
  String id = '123',
  DateTime? startTime,
  DateTime? endTime,
  List<Event> events = const [],
}) {
  final st = startTime ?? DateTime(2024, 7, 1);
  final et = endTime ?? DateTime(2024, 7, 14);
  final json = {
    'id': id,
    'startTime': st.toIso8601String(),
    'endTime': et.toIso8601String(),
    'events': events.map((e) => e.toJson()).toList(),
  };
  return Trip.fromJson(json);
}

void main() {
  group('Trip', () {
    group('Event management', () {
      test('adding event', () {
        final trip = newTrip();
        final event = newEvent();

        trip.addEvent(event);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(event));
      });

      test('removing event', () {
        final trip = newTrip();
        final e1 = newEvent(id: '1');
        final e2 = newEvent(id: '2');
        trip.addEvent(e1);
        trip.addEvent(e2);

        trip.removeEvent(e1);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(e2));
      });

      test('sorting events by timestamp after adding', () {
        final trip = newTrip();
        final older = newEvent(id: '1', timestamp: DateTime(2024, 1, 1));
        final newer = newEvent(id: '2', timestamp: DateTime(2025, 1, 1));

        trip.addEvent(newer);
        trip.addEvent(older);

        expect(trip.events.first, equals(older));
        expect(trip.events.last, equals(newer));
      });

      test('updating event timestamp', () {
        final trip = newTrip(
          startTime: DateTime(2025, 7, 1),
          endTime: DateTime(2025, 7, 14),
        );
        final event = newEvent(timestamp: DateTime(2025, 7, 2));
        trip.addEvent(event);
        final newTime = DateTime(2025, 7, 3);

        trip.updateEventTimestamp(event.id, newTime);

        expect(trip.events.first.timestamp, equals(newTime));
      });

      test('updating does not duplicate event', () {
        final trip = newTrip();
        final event = newEvent();
        trip.addEvent(event);

        trip.updateEventTimestamp(event.id, DateTime(2024, 7, 3));

        expect(trip.events.length, 1);
      });

      test('updating event conserves event id', () {
        final trip = newTrip();
        final eventId = '123';
        final event = newEvent(id: eventId);
        trip.addEvent(event);

        trip.updateEventTimestamp(event.id, DateTime(2024, 7, 3));

        expect(trip.events.first.id, equals(eventId));
      });

      test('sorting events after timestamp update', () {
        final trip = newTrip();
        final older = newEvent(timestamp: DateTime(2024, 7, 4));
        final newer = newEvent(timestamp: DateTime(2024, 7, 5));
        trip.addEvent(older);
        trip.addEvent(newer);

        trip.updateEventTimestamp(newer.id, DateTime(2024, 7, 3));

        expect(trip.events.first.id, equals(newer.id));
      });

      test('updating does nothing if event not found', () {
        final trip = newTrip();

        trip.updateEventTimestamp('666', DateTime(2025));

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
