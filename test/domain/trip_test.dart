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
    group('creation', () {
      test('adding event to trip', () {
        final trip = Trip();
        final event = newEvent();

        trip.addEvent(event);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(event));
      });
      test('sorting events by timestamp after adding', () {
        final trip = Trip();
        final newer = newEvent(id: '1', timestamp: DateTime(2025, 1, 1));
        final older = newEvent(id: '2', timestamp: DateTime(2024, 1, 1));

        trip.addEvent(newer);
        trip.addEvent(older);

        expect(trip.events.first, equals(older));
        expect(trip.events.last, equals(newer));
      });
    });
    group('serialization', () {
      test('Trip serialization/deserialization conserves all fields', () {
        final original = Trip();
        final event = Event(source: EventSource.port, type: EventType.start);
        original.addEvent(event);

        final restored = Trip.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.startTime, original.startTime);
        expect(restored.endTime, original.endTime);
        expect(restored.events.length, 1);
        //        expect(restored.events.first, equals(event));
      });
    });
  });
}
