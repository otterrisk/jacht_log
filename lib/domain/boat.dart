import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/state.dart';
import 'package:jacht_log/domain/timer.dart';
import 'package:jacht_log/domain/trip.dart';

enum BoatMode { stopped, sailing, motoring, afloat }

class Boat extends ChangeNotifier {
  late State state;
  late Timer timer;
  final Trip trip;

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
        timer.update(mode, trip.endTime!);
        break;
      case TripEventAdded(:final event):
        state.update(event);
        timer.update(mode, event.timestamp);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  BoatMode get mode {
    if (state.isOn(EventSource.port) || state.isOn(EventSource.anchor)) {
      return BoatMode.stopped;
    }

    if (state.isOn(EventSource.sail)) {
      return BoatMode.sailing;
    }

    if (state.isOn(EventSource.engine)) {
      return BoatMode.motoring;
    }

    return BoatMode.afloat;
  }

  void toggle(EventSource source) {
    if (state.isOn(source)) {
      trip.addEvent(source, EventType.stop);
    } else {
      trip.addEvent(source, EventType.start);
    }
  }
}
