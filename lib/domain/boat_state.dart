import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';

enum BoatMode { stopped, sailing, motoring, drifting }

class BoatState {
  Map<EventSource, bool> _state;

  BoatState._(this._state);

  static Map<EventSource, bool> _initialState() => {
    EventSource.port: true,
    EventSource.anchor: false,
    EventSource.sail: false,
    EventSource.engine: false,
  };

  factory BoatState.initial() {
    return BoatState._(_initialState());
  }

  factory BoatState.fromTrip(Trip trip) {
    final state = BoatState.initial();
    state.replay(trip);
    return state;
  }

  void rebuild(Trip trip) {
    _reset();
    replay(trip);
  }

  void _reset() {
    _state
      ..clear()
      ..addAll(_initialState());
  }

  void replay(Trip trip) {
    for (final event in trip.events) {
      update(event);
    }
  }

  void update(Event event) {
    switch (event.type) {
      case EventType.start:
        _state[event.source] = true;
        break;
      case EventType.stop:
        _state[event.source] = false;
        break;
    }
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
