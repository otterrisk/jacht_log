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
    state = State();
    timer = Timer(trip.startTime);
    trip.addListener(_onTripChange);
  }

  void _onTripChange() {
    switch (trip.change) {
      case TripStarted():
        state.reset();
        timer.reset(trip.startTime);
        break;
      case TripStopped():
        timer.update(state.mode, trip.endTime!);
        break;
      case TripEventAdded(:final event):
        state.update(event);
        timer.update(state.mode, event.timestamp);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void toggle(EventSource source) {
    if (state.isOn(source)) {
      trip.addEvent(source, EventType.stop);
    } else {
      trip.addEvent(source, EventType.start);
    }
  }
}
