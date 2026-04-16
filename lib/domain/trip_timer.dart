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
  final bool _active;

  DateTime _last;
  BoatMode _mode;

  TripTimer({required Trip trip})
    : assert(trip.startTime != null),
      _active = trip.active,
      _last = trip.startTime!,
      _mode = BoatState.initial().mode {
    _replay(trip);
  }

  void _replay(Trip trip) {
    final state = BoatState.initial();

    for (final event in trip.events) {
      _update(state.mode, event.timestamp);
      state.update(event);
    }

    if (trip.finished) {
      _update(state.mode, trip.endTime!);
    } else {
      _mode = state.mode; // important for last segment
    }
  }

  void _update(BoatMode mode, DateTime timestamp) {
    final delta = timestamp.difference(_last);
    assert(delta >= Duration.zero);

    _mode = mode;
    _time[_mode.counter.index] += delta;
    _last = timestamp;
  }

  @override
  Duration value(TimeCounter counter, DateTime now) {
    var base = _time[counter.index];

    if (_active && counter == _mode.counter) {
      // life delta
      final delta = now.difference(_last);
      assert(delta >= Duration.zero);
      base += delta;
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
