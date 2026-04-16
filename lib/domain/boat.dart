import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/domain/trip_time_view.dart';

class Boat extends ChangeNotifier {
  final Trip trip;

  late BoatState state;
  late TripTimeBase times;

  Boat(this.trip) {
    state = BoatState.fromTrip(trip);
    times = _createTimeView(trip);

    trip.addListener(_onTripChange);
  }

  @override
  void dispose() {
    trip.removeListener(_onTripChange);
    super.dispose();
  }

  void _onTripChange() {
    state = BoatState.fromTrip(trip);
    times = _createTimeView(trip);
    notifyListeners();
  }

  TripTimeBase _createTimeView(Trip trip) {
    if (trip.isStarted) {
      return TripTimeView(trip: trip);
    } else {
      return TripTimeZero();
    }
  }

  void toggle(EventSource source) {
    final type = state.isOn(source) ? EventType.stop : EventType.start;

    trip.addEvent(Event(source: source, type: type, timestamp: DateTime.now()));
  }
}
