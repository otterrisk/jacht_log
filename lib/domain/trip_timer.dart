import 'package:jacht_log/domain/boat_mode.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/trip.dart';

enum TimeCounter { sailing, motoring, stopped }

class TripTimer {
  final List<Duration> _time = List.filled(
    TimeCounter.values.length,
    Duration.zero,
  );
  DateTime _last;

  TripTimer({required final Trip trip}) : _last = trip.startTime {
    _replay(trip);
  }

  List<Duration> get time => List.unmodifiable(_time);

  void update(BoatMode mode, DateTime timestamp) {
    final delta = timestamp.difference(_last);
    assert(delta >= Duration.zero);
    _time[mode.counter.index] += delta;
    _last = timestamp;
  }

  void rebuild(Trip trip) {
    _reset(trip.startTime);
    _replay(trip);
  }

  void _reset(DateTime startTime) {
    _time.fillRange(0, TimeCounter.values.length, Duration.zero);
    _last = startTime;
  }

  void _replay(Trip trip) {
    final state = BoatState.initial();
    for (final e in trip.events) {
      update(state.mode, e.timestamp);
      state.update(e);
    }
    if (!trip.active) {
      update(state.mode, trip.endTime!);
    }
  }
}
