import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/domain/trip_timer.dart';

class Boat extends ChangeNotifier {
  final Trip trip;

  late BoatState state;
  late TripTimerBase timer;

  Boat(this.trip) {
    state = BoatState.fromTrip(trip);
    timer = _createTimer(trip);

    trip.addListener(_onTripChange);
  }

  @override
  void dispose() {
    trip.removeListener(_onTripChange);
    super.dispose();
  }

  TripTimerBase _createTimer(Trip trip) {
    if (trip.started) {
      return TripTimer(trip: trip);
    } else {
      return InactiveTripTimer();
    }
  }

  void _onTripChange() {
    state = BoatState.fromTrip(trip);
    timer = _createTimer(trip);
    notifyListeners();
  }

  void toggle(EventSource source) {
    final type = state.isOn(source) ? EventType.stop : EventType.start;

    trip.addEvent(Event(source: source, type: type, timestamp: DateTime.now()));
  }
}
