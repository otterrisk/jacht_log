import 'package:jacht_log/domain/boat_mode.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/trip.dart';

enum TimeCounter { sailing, motoring, stopped }

abstract class TripTimerBase {
  Duration value(TimeCounter counter, DateTime now);
  Duration total(DateTime now);
}

class InactiveTripTimer implements TripTimerBase {
  @override
  Duration value(TimeCounter counter, DateTime now) => Duration.zero;

  @override
  Duration total(DateTime now) => Duration.zero;
}

class TripTimer implements TripTimerBase {
  final List<Duration> _time = List.filled(
    TimeCounter.values.length,
    Duration.zero,
  );

  DateTime _last;
  BoatMode _mode;

  TripTimer({required Trip trip})
    : assert(trip.startTime != null),
      _last = trip.startTime!,
      _mode = BoatState.initial().mode {
    _replay(trip);
  }

  void update(BoatMode mode, DateTime timestamp) {
    final delta = timestamp.difference(_last);
    assert(delta >= Duration.zero);

    _time[_mode.counter.index] += delta;
    _last = timestamp;
    _mode = mode;
  }

  void rebuild(Trip trip) {
    _reset(trip);
    _replay(trip);
  }

  void _reset(Trip trip) {
    _time.fillRange(0, _time.length, Duration.zero);
    _last = trip.startTime!;
    _mode = BoatState.initial().mode;
  }

  void _replay(Trip trip) {
    final state = BoatState.initial();

    for (final e in trip.events) {
      update(state.mode, e.timestamp);
      state.update(e);
    }

    if (trip.finished) {
      update(state.mode, trip.endTime!);
    } else {
      _mode = state.mode; // important for live delta
    }
  }

  @override
  Duration value(TimeCounter counter, DateTime now) {
    final base = _time[counter.index];

    if (counter == _mode.counter) {
      final delta = now.difference(_last);
      return delta.isNegative ? base : base + delta;
    }

    return base;
  }

  @override
  Duration total(DateTime now) {
    return TimeCounter.values
        .map((c) => value(c, now))
        .fold(Duration.zero, (a, b) => a + b);
  }
}
