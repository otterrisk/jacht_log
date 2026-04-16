import 'package:jacht_log/domain/trip.dart';

enum TripStatus { notStarted, active, finished }

extension TripStatusX on Trip {
  TripStatus get status {
    if (!isStarted) return TripStatus.notStarted;
    if (!isFinished) return TripStatus.active;
    return TripStatus.finished;
  }
}
