import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';

void main() {
  group('Event', () {
    group('toJson', () {
      test('returns a valid map', () {
        final event = Event(
          source: EventSource.port,
          type: EventType.start,
          timestamp: DateTime(2024, 8, 1),
        );

        final json = event.toJson();

        expect(json['id'], event.id);
        expect(json['source'], 'port');
        expect(json['type'], 'start');
        expect(json['timestamp'], event.timestamp.toIso8601String());
      });
    });

    group('fromJson', () {
      test('creates Event from map', () {
        final json = {
          'id': '123',
          'source': 'port',
          'type': 'start',
          'timestamp': '2024-01-01T12:00:00Z',
        };

        final event = Event.fromJson(json);

        expect(event.id, '123');
        expect(event.source, EventSource.port);
        expect(event.type, EventType.start);
        expect(event.timestamp, DateTime.parse('2024-01-01T12:00:00Z'));
      });
    });

    group('serialization round-trip', () {
      test('toJson -> fromJson preserves data', () {
        final original = Event(
          source: EventSource.port,
          type: EventType.start,
          timestamp: DateTime(2024, 8, 1),
        );

        final json = original.toJson();
        final restored = Event.fromJson(json);

        expect(restored, original);
      });
    });

    group('equality', () {
      test('events with different fields are equal', () {
        final e1 = Event.fromJson({
          'id': '1',
          'source': EventSource.port.name,
          'type': EventType.start.name,
          'timestamp': '2024-01-01T12:00:00Z',
        });
        final e2 = Event.fromJson({
          'id': '1',
          'source': EventSource.anchor.name,
          'type': EventType.stop.name,
          'timestamp': '2025-12-31T11:11:11Z',
        });

        final result = e1 == e2;

        expect(result, true);
      });

      test('events with different id are not equal', () {
        final e1 = Event.fromJson({
          'id': '1',
          'source': EventSource.port.name,
          'type': EventType.start.name,
          'timestamp': DateTime.now().toIso8601String(),
        });
        final e2 = Event.fromJson({
          'id': '2',
          'source': e1.source.name,
          'type': e1.type.name,
          'timestamp': e1.timestamp.toIso8601String(),
        });

        final result = e1 == e2;

        expect(result, false);
      });
    });
  });
}
