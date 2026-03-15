import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/timer.dart';
import 'package:jacht_log/domain/trip.dart';

enum BoatMode { stopped, sailing, motoring, afloat }

class Boat extends ChangeNotifier {
  final Trip trip;
  late Timer timer;
  final Map<EventSource, bool> state = {
    for (final source in EventSource.values) source: false,
    EventSource.port: true,
  };

  Boat(this.trip) {
    timer = Timer(trip.startTime);
    trip.addListener(_onTripChange);
  }

  void _onTripChange() {
    switch (trip.change) {
      case TripStarted():
        timer.reset(trip.startTime);
        resetState();
        break;
      case TripStopped():
        timer.update(mode, trip.endTime!);
        break;
      case TripEventAdded(:final event):
        timer.update(mode, event.timestamp);
        updateState(event);
        break;
      default:
        break;
    }
    notifyListeners();
  }

  void resetState() {
    for (final source in EventSource.values) {
      if (source == EventSource.port) {
        state[source] = true;
      } else {
        state[source] = false;
      }
    }
  }

  void updateState(final Event event) {
    state[event.source] = event.type == EventType.start;
  }

  bool isOn(EventSource source) => state[source] == true;

  BoatMode get mode {
    if (isOn(EventSource.port) || isOn(EventSource.anchor)) {
      return BoatMode.stopped;
    }

    if (isOn(EventSource.sail)) {
      return BoatMode.sailing;
    }

    if (isOn(EventSource.engine)) {
      return BoatMode.motoring;
    }

    return BoatMode.afloat;
  }

  void toggle(EventSource source) {
    if (state[source] == true) {
      trip.addEvent(source, EventType.stop);
    } else {
      trip.addEvent(source, EventType.start);
    }
  }
}
