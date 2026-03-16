import 'package:jacht_log/domain/state.dart';
import 'package:jacht_log/domain/trip.dart';

enum TimeCounter { sailing, motoring, stopped }

class Timer {
  final List<Duration> time = List.filled(
    TimeCounter.values.length,
    Duration.zero,
  );
  DateTime last;

  Timer({required final Trip trip}) : last = trip.startTime {
    replay(trip);
  }

  void replay(final Trip trip) {
    final state = State();
    for (final e in trip.events) {
      update(state.mode, e.timestamp);
      state.update(e);
    }
    if (!trip.active) {
      update(state.mode, trip.endTime!);
    }
  }

  void update(BoatMode mode, DateTime timestamp) {
    time[counter(mode).index] += timestamp.difference(last);
    last = timestamp;
  }

  TimeCounter counter(BoatMode mode) {
    switch (mode) {
      case BoatMode.stopped:
        return TimeCounter.stopped;

      case BoatMode.sailing:
      case BoatMode.drifting:
        return TimeCounter.sailing;

      case BoatMode.motoring:
        return TimeCounter.motoring;
    }
  }
}
