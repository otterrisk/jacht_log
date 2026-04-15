import 'package:jacht_log/domain/trip_timer.dart';

class TimeTableViewModel {
  final Map<TimeCounter, Duration> values;
  final Duration total;

  TimeTableViewModel({required this.values, required this.total});

  factory TimeTableViewModel.create({
    required TripTimerBase timer,
    required DateTime now,
  }) {
    final values = {for (final c in TimeCounter.values) c: timer.value(c, now)};

    final total = timer.total(now);

    return TimeTableViewModel(values: values, total: total);
  }
}
