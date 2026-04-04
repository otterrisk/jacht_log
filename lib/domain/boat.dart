import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/state.dart';
import 'package:jacht_log/domain/timer.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/domain/trip_change.dart';

class Boat extends ChangeNotifier {
  final Trip trip;
  late State state;
  late Timer timer;

  Boat(this.trip) {
    state = State(trip: trip);
    timer = Timer(trip: trip);
    trip.addListener(_onTripChange);
  }

  @override
  void dispose() {
    trip.removeListener(_onTripChange);
    super.dispose();
  }

  void _onTripChange() {
    switch (trip.change) {
      case TripStarted():
        timer.update(state.mode, DateTime.now());
        break;
      case TripStopped():
        timer.update(state.mode, trip.endTime!);
        break;
      case EventAdded():
      case EventRemoved():
      case EventUpdated():
        timer.rebuild(trip);
        state.rebuild(trip);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void toggle(EventSource source) {
    EventType type;
    if (state.isOn(source)) {
      type = EventType.stop;
    } else {
      type = EventType.start;
    }
    trip.addEvent(Event(source: source, type: type, timestamp: DateTime.now()));
  }
}
