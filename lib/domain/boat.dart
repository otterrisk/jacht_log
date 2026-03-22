import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/state.dart';
import 'package:jacht_log/domain/timer.dart';
import 'package:jacht_log/domain/trip.dart';

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
      case EventAdded(:final event):
        timer.update(state.mode, event.timestamp);
        state.update(event);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void toggle(EventSource source) {
    if (state.isOn(source)) {
      trip.addEvent(Event(source: source, type: EventType.stop));
    } else {
      trip.addEvent(Event(source: source, type: EventType.start));
    }
  }
}
