import 'package:jacht_log/domain/event.dart';

class State {
  final Map<EventSource, bool> _state = {
    for (final source in EventSource.values) source: false,
    EventSource.port: true,
  };

  bool isOn(EventSource source) => _state[source] == true;

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
