import 'package:jacht_log/domain/mode.dart';

enum TimeCounter { sailing, motoring, stopped }

class Timer {
  final List<Duration> time = List.filled(
    TimeCounter.values.length,
    Duration.zero,
  );
  DateTime last;

  Timer(this.last);

  void update(BoatMode mode, DateTime timestamp) {
    time[counter(mode).index] += timestamp.difference(last);
    last = timestamp;
  }

  void reset() {
    time.fillRange(0, time.length, Duration.zero);
  }

  TimeCounter counter(BoatMode mode) {
    switch (mode) {
      case BoatMode.stopped:
        return TimeCounter.stopped;

      case BoatMode.sailing:
      case BoatMode.afloat:
        return TimeCounter.sailing;

      case BoatMode.motoring:
        return TimeCounter.motoring;
    }
  }
}
