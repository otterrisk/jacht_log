import 'package:jacht_log/domain/boat_mode.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/trip_timer.dart';

class TimeTableViewModel {
  final Map<TimeCounter, Duration> values;
  final Duration total;

  TimeTableViewModel({required this.values, required this.total});

  factory TimeTableViewModel.create({
    required TripTimer timer,
    required BoatState state,
    required bool isActive,
    required DateTime now,
  }) {
    final liveDelta = now.difference(timer.last).isNegative
        ? Duration.zero
        : now.difference(timer.last);

    final currentCounter = state.mode.counter;

    Duration value(TimeCounter counter) {
      final base = timer.time[counter.index];

      if (counter == currentCounter && isActive) {
        return base + liveDelta;
      }
      return base;
    }

    final values = {for (final c in TimeCounter.values) c: value(c)};

    final total = values.values.fold(Duration.zero, (sum, d) => sum + d);

    return TimeTableViewModel(values: values, total: total);
  }
}
