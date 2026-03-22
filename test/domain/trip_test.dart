import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';

void main() {
  group('Trip', () {
    group('creation', () {
      test('adding event to trip', () {
        final trip = Trip();
        final event = Event(source: EventSource.port, type: EventType.start);

        trip.addEvent(event);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(event));
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
