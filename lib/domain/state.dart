import 'package:jacht_log/domain/event.dart';

enum BoatMode { stopped, sailing, motoring, afloat }

class State {
  final Map<EventSource, bool> _state = {
    for (final source in EventSource.values) source: false,
    EventSource.port: true,
  };

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

    return BoatMode.afloat;
  }

  void update(final Event event) {
    _state[event.source] = event.type == EventType.start;
  }

  void reset() {
    for (final source in EventSource.values) {
      if (source == EventSource.port) {
        _state[source] = true;
      } else {
        _state[source] = false;
      }
    }
  }
}
