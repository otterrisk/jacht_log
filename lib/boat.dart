import 'package:flutter/foundation.dart';
import 'package:jacht_log/event.dart';
import 'package:jacht_log/trip.dart';

enum Mode { idle, stopped, sailing, motoring, afloat }

class Boat extends ChangeNotifier {
  final Trip trip;
  final Map<EventSource, bool> state = {
    for (final source in EventSource.values) source: false,
    EventSource.port: true,
  };
  final List<Duration> time = List.filled(Mode.values.length, Duration.zero);
  DateTime? lastTime;

  Boat(this.trip) {
    trip.addListener(_update);
    _update();
  }

  void _update() {
    if (trip.events.isEmpty) {
      resetTime();
      resetState();
      return;
    }
    final event = trip.events.last;
    updateTime(event);
    updateState(event);
    notifyListeners();
  }

  void resetTime() {
    time.fillRange(0, time.length, Duration.zero);
    lastTime = null;
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
    notifyListeners();
  }

  void updateTime(Event event) {
    if (lastTime != null) {
      time[mode.index] += event.timestamp.difference(lastTime!);
    }
    lastTime = event.timestamp;
  }

  void updateState(final Event event) {
    state[event.source] = event.type == EventType.start;
  }

  bool isOn(EventSource source) => state[source] == true;

  Mode get mode {
    if (!trip.active) {
      return Mode.idle;
    }

    if (isOn(EventSource.port) || isOn(EventSource.anchor)) {
      return Mode.stopped;
    }

    if (isOn(EventSource.sail)) {
      return Mode.sailing;
    }

    if (isOn(EventSource.engine)) {
      return Mode.motoring;
    }

    return Mode.afloat;
  }

  void toggle(EventSource source) {
    if (state[source] == true) {
      trip.addEvent(source, EventType.stop);
    } else {
      trip.addEvent(source, EventType.start);
    }
  }
}
