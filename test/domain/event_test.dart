import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';

void main() {
  group('Event', () {
    group('toJson', () {
      test('returns a valid map', () {
        final event = Event(
          id: '123',
          source: EventSource.port,
          type: EventType.start,
          timestamp: DateTime.parse('2024-01-01T12:00:00Z'),
        );

        final json = event.toJson();

        expect(json['id'], '123');
        expect(json['source'], 'port');
        expect(json['type'], 'start');
        expect(json['timestamp'], '2024-01-01T12:00:00.000Z');
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
          id: 'abc',
          source: EventSource.port,
          type: EventType.start,
          timestamp: DateTime.now(),
        );

        final json = original.toJson();
        final restored = Event.fromJson(json);

        expect(restored, original);
      });
    });

    group('equality', () {
      test('events with different fields are equal', () {
        final e1 = Event(
          id: '1',
          source: EventSource.port,
          type: EventType.start,
          timestamp: DateTime.parse('2024-01-01T12:00:00Z'),
        );
        final e2 = Event(
          id: '1',
          source: EventSource.anchor,
          type: EventType.stop,
          timestamp: DateTime.parse('2025-12-31T11:11:11Z'),
        );

        final result = e1 == e2;

        expect(result, true);
      });

      test('events with different id are not equal', () {
        final e1 = Event(
          id: '1',
          source: EventSource.port,
          type: EventType.start,
          timestamp: DateTime.now(),
        );
        final e2 = Event(
          id: '2',
          source: e1.source,
          type: e1.type,
          timestamp: e1.timestamp,
        );

        final result = e1 == e2;

        expect(result, false);
      });
    });
  });
}
