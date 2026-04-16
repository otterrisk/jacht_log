import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/domain/trip_time_view.dart';

import 'fixtures.dart';

Trip newTrip({
  String id = '123',
  DateTime? startTime,
  DateTime? endTime,
  List<Event> events = const [],
}) {
  final json = {
    'id': id,
    'startTime': startTime?.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'events': events.map((e) => e.toJson()).toList(),
  };
  return Trip.fromJson(json);
}

void main() {
  group('TripTimeZero', () {
    test('always returns zeros', () {
      final times = TripTimeZero();
      final now = DateTime.now();

      for (final c in TimeCounter.values) {
        expect(times.value(c, now), Duration.zero);
      }

      expect(times.total(now), Duration.zero);
    });
  });
  group('TripTimeView', () {
    group('basic scenarios', () {
      test('returns zero durations when no events after start', () {
        final start = DateTime(2024, 5, 1, 10);
        final trip = newTrip(startTime: start);

        final times = TripTimeView(trip: trip);

        final now = start.add(const Duration(hours: 2));

        expect(times.value(TimeCounter.sailing, now), Duration.zero);
        expect(times.value(TimeCounter.motoring, now), Duration.zero);
        expect(times.value(TimeCounter.stopped, now), const Duration(hours: 2));
      });

      test('counts time between start and first event in initial mode', () {
        final start = DateTime(2024, 5, 1, 10);
        final t1 = start.add(const Duration(hours: 1));

        final trip = newTrip(
          startTime: start,
          events: [
            newEvent(
              timestamp: t1,
              source: EventSource.engine,
              type: EventType.start,
            ),
          ],
        );

        final times = TripTimeView(trip: trip);

        expect(times.value(TimeCounter.stopped, t1), const Duration(hours: 1));
      });

      test('splits time across counters correctly', () {
        final start = DateTime(2024, 5, 1, 10); // 10:00
        final t1 = start.add(const Duration(hours: 1)); // 11:00
        final t2 = start.add(const Duration(hours: 2)); // 12:00

        final trip = newTrip(
          startTime: start,
          events: [
            newEvent(
              timestamp: t1,
              source: EventSource.engine,
              type: EventType.start,
            ),
            newEvent(
              timestamp: t1,
              source: EventSource.port,
              type: EventType.stop,
            ),
            newEvent(
              timestamp: t2,
              source: EventSource.engine,
              type: EventType.stop,
            ),
          ],
        );

        final times = TripTimeView(trip: trip);

        expect(times.value(TimeCounter.stopped, t2), const Duration(hours: 1));
        expect(times.value(TimeCounter.motoring, t2), const Duration(hours: 1));
      });
    });

    group('live delta', () {
      test('adds live delta to current counter when trip is active', () {
        final start = DateTime(2024, 5, 1, 10);
        final t1 = start.add(const Duration(hours: 1));
        final now = start.add(const Duration(hours: 3));

        final trip = newTrip(
          startTime: start,
          // 10:00 stopped
          events: [
            newEvent(
              timestamp: t1,
              source: EventSource.engine,
              type: EventType.start,
            ),
            newEvent(
              timestamp: t1,
              source: EventSource.port,
              type: EventType.stop,
            ),
            // 11:00 motoring
          ],
        );

        final times = TripTimeView(trip: trip);

        expect(trip.isActive, true);
        expect(times.value(TimeCounter.stopped, now), const Duration(hours: 1));
        expect(
          times.value(TimeCounter.motoring, now),
          const Duration(hours: 2),
        );
      });

      test(
        'does not add live delta to non-current counters when trip is active',
        () {
          final start = DateTime(2024, 5, 1, 10);
          final now = start.add(const Duration(hours: 2));

          final trip = newTrip(startTime: start);

          final times = TripTimeView(trip: trip);

          expect(trip.isActive, true);
          expect(times.value(TimeCounter.sailing, now), Duration.zero);
        },
      );

      test('does not add live delta when trip is finished', () {
        final start = DateTime(2024, 5, 1, 10);
        final end = start.add(const Duration(hours: 2));

        final trip = newTrip(startTime: start, endTime: end);

        final times = TripTimeView(trip: trip);

        final now = end.add(const Duration(hours: 5));

        expect(trip.isFinished, true);
        expect(times.value(TimeCounter.stopped, now), const Duration(hours: 2));
      });
    });
    group('total', () {
      test('total equals sum of all counters', () {
        final start = DateTime(2024, 5, 1, 10);
        final t1 = start.add(const Duration(hours: 1));
        final t2 = start.add(const Duration(hours: 2));
        final now = start.add(const Duration(hours: 3));

        final trip = newTrip(
          startTime: start,
          // 10:00 stopped
          events: [
            newEvent(
              timestamp: t1,
              source: EventSource.engine,
              type: EventType.start,
            ),
            newEvent(
              timestamp: t1,
              source: EventSource.port,
              type: EventType.stop,
            ),
            // 11:00 motoring
            newEvent(
              timestamp: t2,
              source: EventSource.sail,
              type: EventType.start,
            ),
            // 12:00 sailing
          ],
        );

        final times = TripTimeView(trip: trip);

        final total = times.total(now);

        final sum = TimeCounter.values
            .map((c) => times.value(c, now))
            .reduce((a, b) => a + b);

        expect(times.value(TimeCounter.sailing, now), const Duration(hours: 1));
        expect(
          times.value(TimeCounter.motoring, now),
          const Duration(hours: 1),
        );
        expect(times.value(TimeCounter.stopped, now), const Duration(hours: 1));

        expect(total, sum);
      });

      test('total time equals now - startTime when trip is active', () {
        final start = DateTime(2024, 5, 1, 10);
        final t1 = start.add(const Duration(hours: 1));
        final t2 = start.add(const Duration(hours: 2));
        final now = start.add(const Duration(hours: 5));

        final trip = newTrip(
          startTime: start,
          // 10:00 stopped
          events: [
            newEvent(
              timestamp: t1,
              source: EventSource.engine,
              type: EventType.start,
            ),
            newEvent(
              timestamp: t1,
              source: EventSource.port,
              type: EventType.stop,
            ),
            // 11:00 motoring
            newEvent(
              timestamp: t2,
              source: EventSource.sail,
              type: EventType.start,
            ),
            // 12:00 sailing
          ],
        );

        final times = TripTimeView(trip: trip);

        // 15:00 now
        expect(trip.isActive, true);
        expect(times.total(now), now.difference(start));
      });

      test('total time equals endTime - startTime when trip is finished', () {
        final start = DateTime(2024, 5, 1, 10);
        final t1 = start.add(const Duration(hours: 1));
        final t2 = start.add(const Duration(hours: 2));
        final end = start.add(const Duration(hours: 3));
        final now = start.add(const Duration(hours: 5));

        final trip = newTrip(
          startTime: start,
          // 10:00 start
          events: [
            newEvent(
              timestamp: t1,
              source: EventSource.engine,
              type: EventType.start,
            ),
            newEvent(
              timestamp: t1,
              source: EventSource.port,
              type: EventType.stop,
            ),
            // 11:00 motoring
            newEvent(
              timestamp: t2,
              source: EventSource.sail,
              type: EventType.start,
            ),
            // 12:00 sailing
          ],
          endTime: end,
          // 13:00 end
        );

        final times = TripTimeView(trip: trip);

        // 15:00 now
        expect(trip.isFinished, true);
        expect(times.total(now), end.difference(start));
      });
    });
  });
}
