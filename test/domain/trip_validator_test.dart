import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip_validator.dart';

import 'fixtures.dart';

void main() {
  group('TripValidator', () {
    group('validate', () {
      test('no events -> no issues', () {
        final trip = newTrip(events: []);

        final issues = TripValidator().validate(trip);

        expect(issues, isEmpty);
      });

      test('valid start-stop sequence -> no issues', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.engine,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
            newEvent(
              id: '2',
              source: EventSource.engine,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 4),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, isEmpty);
      });

      test('duplicate start -> error', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.sail,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
            newEvent(
              id: '2',
              source: EventSource.sail,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 4),
            ),
            newEvent(
              id: '3',
              source: EventSource.sail,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 5),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, hasLength(1));
        expect(issues.first.code, ValidationCode.duplicateStart);
        expect(issues.first.event.id, '2');
        expect(issues.first.relatedEvent?.id, '1');
      });

      test('duplicate stop -> error', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.sail,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
            newEvent(
              id: '2',
              source: EventSource.sail,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 4),
            ),
            newEvent(
              id: '3',
              source: EventSource.sail,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 5),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, hasLength(1));
        expect(issues.first.code, ValidationCode.duplicateStop);
        expect(issues.first.event.id, '3');
        expect(issues.first.relatedEvent?.id, '2');
      });

      test('port starts ON so first event must be stop', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.port,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
            newEvent(
              id: '2',
              source: EventSource.port,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 4),
            ),
            newEvent(
              id: '3',
              source: EventSource.port,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 5),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, hasLength(1));
        expect(issues.first.code, ValidationCode.duplicateStart);
      });

      test('port ends ON -> no warning', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.port,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 3),
            ),
            newEvent(
              id: '2',
              source: EventSource.port,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 4),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, isEmpty);
      });

      test('sail starts OFF so first event must be start', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.sail,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 3),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, hasLength(1));
        expect(issues.first.code, ValidationCode.duplicateStop);
      });

      test('sail ends ON -> warning', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.sail,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, hasLength(1));
        expect(issues.first.code, ValidationCode.invalidFinalState);
      });

      test('different sources are independent', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.engine,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
            newEvent(
              id: '2',
              source: EventSource.sail,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 4),
            ),
            newEvent(
              id: '3',
              source: EventSource.engine,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 5),
            ),
            newEvent(
              id: '4',
              source: EventSource.sail,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 6),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, isEmpty);
      });

      test('error in one source does not affect others', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '1',
              source: EventSource.engine,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
            newEvent(
              id: '2',
              source: EventSource.engine,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 4),
            ),
            newEvent(
              id: '3',
              source: EventSource.engine,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 5),
            ), // błąd
            newEvent(
              id: '4',
              source: EventSource.sail,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 6),
            ),
            newEvent(
              id: '5',
              source: EventSource.sail,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 7),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, hasLength(1));
        expect(issues.first.code, ValidationCode.duplicateStart);
      });

      test('events are validated in timestamp order', () {
        final trip = newTrip(
          events: [
            newEvent(
              id: '2',
              source: EventSource.sail,
              type: EventType.stop,
              timestamp: DateTime(2024, 7, 4),
            ),
            newEvent(
              id: '1',
              source: EventSource.sail,
              type: EventType.start,
              timestamp: DateTime(2024, 7, 3),
            ),
          ],
        );

        final issues = TripValidator().validate(trip);

        expect(issues, isEmpty);
      });
    });
  });
}
