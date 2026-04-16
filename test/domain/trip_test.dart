import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/exception.dart';
import 'package:jacht_log/domain/trip.dart';

import 'fixtures.dart';

void main() {
  group('Trip', () {
    group('addEvent', () {
      test('adding event', () {
        final trip = newTrip(startTime: DateTime(2024, 7, 1));
        final event = newEvent();

        trip.addEvent(event);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(event));
      });

      test('cannot add event if trip not started', () {
        final trip = Trip();

        expect(
          () => trip.addEvent(newEvent()),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.tripNotStarted,
            ),
          ),
        );
      });

      test('can add event if trip finished', () {
        final trip = newTrip(
          startTime: DateTime(2024, 1, 1, 12),
          endTime: DateTime(2024, 1, 1, 13),
        );

        final event = newEvent(timestamp: DateTime(2024, 1, 1, 12, 30));

        trip.addEvent(event);

        expect(trip.events, contains(event));
      });

      test('cannot add event outside trip bounds', () {
        final trip = newTrip(
          startTime: DateTime(2024, 7, 1),
          endTime: DateTime(2024, 7, 14),
        );

        expect(
          () => trip.addEvent(newEvent(timestamp: DateTime(2023, 1, 1))),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.eventBeforeTripStart,
            ),
          ),
        );

        expect(
          () => trip.addEvent(newEvent(timestamp: DateTime(2025, 1, 1))),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.eventAfterTripEnd,
            ),
          ),
        );
      });

      test('sorting events by timestamp after adding', () {
        final trip = newTrip(startTime: DateTime(2024, 7, 1));
        final older = newEvent(id: '1', timestamp: DateTime(2024, 7, 3));
        final newer = newEvent(id: '2', timestamp: DateTime(2024, 7, 4));

        trip.addEvent(newer);
        trip.addEvent(older);

        expect(trip.events.first, equals(older));
        expect(trip.events.last, equals(newer));
      });
    });

    group('removeEvent', () {
      test('removing event', () {
        final trip = newTrip(startTime: DateTime(2024, 7, 1));
        final e1 = newEvent(id: '1');
        final e2 = newEvent(id: '2');
        trip.addEvent(e1);
        trip.addEvent(e2);

        trip.removeEvent(e1.id);

        expect(trip.events.length, 1);
        expect(trip.events.first, equals(e2));
      });

      test('removing event that could not be found', () {
        final trip = newTrip(startTime: DateTime(2024, 7, 1));

        expect(
          () => trip.removeEvent('missing'),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.eventNotFound,
            ),
          ),
        );
      });
    });

    group('updateEventTimestamp', () {
      test('updating event timestamp within bounds', () {
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

      test('cannot move event outside bounds', () {
        final trip = newTrip(
          startTime: DateTime(2025, 7, 1),
          endTime: DateTime(2025, 7, 14),
        );

        final event = newEvent(timestamp: DateTime(2025, 7, 2));
        trip.addEvent(event);

        expect(
          () => trip.updateEventTimestamp(event.id, DateTime(2025, 6, 15)),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.eventBeforeTripStart,
            ),
          ),
        );

        expect(
          () => trip.updateEventTimestamp(event.id, DateTime(2025, 7, 20)),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.eventAfterTripEnd,
            ),
          ),
        );
      });

      test('updating preserves identity and sorting', () {
        final trip = newTrip(startTime: DateTime(2024, 7, 1));

        final e1 = newEvent(id: '1', timestamp: DateTime(2024, 7, 4));
        final e2 = newEvent(id: '2', timestamp: DateTime(2024, 7, 5));

        trip.addEvent(e1);
        trip.addEvent(e2);

        trip.updateEventTimestamp(e2.id, DateTime(2024, 7, 3));

        expect(trip.events.length, 2);
        expect(trip.events.first.id, '2');
      });

      test('updating event that could not be found', () {
        final trip = newTrip(startTime: DateTime(2024, 7, 1));

        expect(
          () => trip.updateEventTimestamp('666', DateTime(2025)),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.eventNotFound,
            ),
          ),
        );
      });
    });

    group('time editing', () {
      test('cannot set startTime after existing event', () {
        final start = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: start);

        final event = newEvent(timestamp: start.add(Duration(hours: 1)));
        trip.addEvent(event);

        expect(
          () => trip.setStartTime(start.add(Duration(hours: 2))),
          throwsA(isA<DomainException>()),
        );
      });

      test('can set startTime equal to event timestamp', () {
        final start = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: start);

        final event = newEvent(timestamp: start.add(Duration(hours: 1)));
        trip.addEvent(event);

        expect(() => trip.setStartTime(event.timestamp), returnsNormally);
      });

      test('cannot set endTime before existing event', () {
        final start = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: start);

        final event = newEvent(timestamp: start.add(Duration(hours: 2)));
        trip.addEvent(event);

        expect(
          () => trip.setEndTime(start.add(Duration(hours: 1))),
          throwsA(isA<DomainException>()),
        );
      });

      test('can set endTime equal to event timestamp', () {
        final start = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: start);

        final event = newEvent(timestamp: start.add(Duration(hours: 2)));
        trip.addEvent(event);

        expect(() => trip.setEndTime(event.timestamp), returnsNormally);
      });

      test('cannot set endTime before startTime', () {
        final start = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: start);

        expect(
          () => trip.setEndTime(start.subtract(Duration(seconds: 1))),
          throwsA(isA<DomainException>()),
        );
      });

      test('can set startTime equal to endTime', () {
        final time = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: time);

        expect(() => trip.setEndTime(time), returnsNormally);
      });

      test('setStartTime rolls back on validation error', () {
        final start = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: start);

        final event = newEvent(timestamp: start.add(Duration(hours: 1)));
        trip.addEvent(event);

        try {
          trip.setStartTime(start.add(Duration(hours: 2)));
        } catch (_) {}

        expect(trip.startTime, start);
      });
    });

    group('serialization', () {
      test('serialization/deserialization conserves all fields', () {
        final original = newTrip(startTime: DateTime(2024, 7, 1));
        final event = newEvent();
        original.addEvent(event);

        final restored = Trip.fromJson(original.toJson());

        expect(restored.id, original.id);
        expect(restored.startTime, original.startTime);
        expect(restored.endTime, original.endTime);
        expect(restored.events.length, 1);
        expect(restored.events.first, equals(event));
      });

      test('fromJson supports trip without startTime', () {
        final json = {
          'id': '1',
          'startTime': null,
          'endTime': null,
          'events': [],
        };

        final trip = Trip.fromJson(json);

        expect(trip.isStarted, false);
      });

      test('fromJson fails when events exist but trip not started', () {
        final json = {
          'id': '1',
          'startTime': null,
          'endTime': null,
          'events': [newEvent().toJson()],
        };

        expect(
          () => Trip.fromJson(json),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.tripNotStarted,
            ),
          ),
        );
      });

      test('invalid endTime on deserialization', () {
        final json = {
          'id': '123',
          'startTime': '2024-07-01',
          'endTime': '2024-06-01',
          'events': [],
        };

        expect(
          () => Trip.fromJson(json),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.tripEndBeforeTripStart,
            ),
          ),
        );
      });

      test('invalid event on deserialization', () {
        final json = {
          'id': '123',
          'startTime': '2024-07-01',
          'endTime': '2024-07-14',
          'events': [
            {
              'id': '456',
              'source': 'engine',
              'type': 'start',
              'timestamp': '2024-08-01',
            },
          ],
        };

        expect(
          () => Trip.fromJson(json),
          throwsA(
            isA<DomainException>().having(
              (e) => e.error,
              'error',
              DomainError.eventAfterTripEnd,
            ),
          ),
        );
      });

      test('event sorting on deserialization', () {
        final json = {
          'id': '123',
          'startTime': '2024-07-01',
          'endTime': '2024-07-14',
          'events': [
            newEvent(id: '2', timestamp: DateTime(2024, 7, 3)).toJson(),
            newEvent(id: '1', timestamp: DateTime(2024, 7, 2)).toJson(),
          ],
        };

        final trip = Trip.fromJson(json);

        expect(trip.events.first.id, '1');
        expect(trip.events.last.id, '2');
      });
    });
  });
}
