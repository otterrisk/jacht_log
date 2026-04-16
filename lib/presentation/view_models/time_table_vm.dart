import 'package:jacht_log/domain/trip_time_view.dart';

class TimeTableViewModel {
  final Map<TimeCounter, Duration> values;
  final Duration total;

  TimeTableViewModel({required this.values, required this.total});

  factory TimeTableViewModel.create({
    required TripTimeBase times,
    required DateTime now,
  }) {
    final values = {for (final c in TimeCounter.values) c: times.value(c, now)};

    final total = times.total(now);

    return TimeTableViewModel(values: values, total: total);
  }
}
