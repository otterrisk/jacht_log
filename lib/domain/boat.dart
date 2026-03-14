import 'package:flutter/foundation.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/mode.dart';
import 'package:jacht_log/domain/trip.dart';

class Boat extends ChangeNotifier {
  final Trip trip;
  final Map<EventSource, bool> state = {
    for (final source in EventSource.values) source: false,
    EventSource.port: true,
  };
  final List<Duration> time = List.filled(
    TimeCounter.values.length,
    Duration.zero,
  );
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
      time[counter(mode).index] += event.timestamp.difference(lastTime!);
    }
    lastTime = event.timestamp;
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

  TimeCounter counter(BoatMode mode) {
    switch (mode) {
      case BoatMode.stopped:
        return TimeCounter.stopped;

      case BoatMode.sailing:
      case BoatMode.afloat:
        return TimeCounter.sailing;

      case BoatMode.motoring:
        return TimeCounter.motoring;
    }
  }

  void toggle(EventSource source) {
    if (state[source] == true) {
      trip.addEvent(source, EventType.stop);
    } else {
      trip.addEvent(source, EventType.start);
    }
  }
}
