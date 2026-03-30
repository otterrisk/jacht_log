import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';

enum BoatMode { stopped, sailing, motoring, drifting }

class State {
  final Map<EventSource, bool> _state = {
    for (final source in EventSource.values) source: false,
    EventSource.port: true,
  };

  State({final Trip? trip}) {
    if (trip != null) {
      replay(trip);
    }
  }

  void rebuild(Trip trip) {
    reset();
    replay(trip);
  }

  void reset() {
    _state.clear();
    for (final source in EventSource.values) {
      _state[source] = false;
    }
    _state[EventSource.port] = true;
  }

  void replay(Trip trip) {
    for (final e in trip.events) {
      update(e);
    }
  }

  void update(Event event) {
    _state[event.source] = event.type == EventType.start;
  }

  bool isOn(EventSource source) => _state[source] == true;

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

    return BoatMode.drifting;
  }
}
