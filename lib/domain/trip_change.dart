import 'package:jacht_log/domain/event.dart';

sealed class TripChange {}

class TripStarted extends TripChange {}

class TripStopped extends TripChange {}

class EventAdded extends TripChange {
  final Event event;
  EventAdded(this.event);
}

class EventUpdated extends TripChange {
  final Event event;
  EventUpdated(this.event);
}

class EventRemoved extends TripChange {
  final Event event;
  EventRemoved(this.event);
}
