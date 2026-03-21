import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';

void main() {
  group('Trip', () {
    group('serialization', () {
      test('Trip serialization/deserialization conserves all fields', () {
        final original = Trip();
        final event = Event(
          source: EventSource.port,
          type: EventType.start,
          timestamp: DateTime(2024, 1, 1),
        );
        original.addEvent(event.source, event.type);

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
