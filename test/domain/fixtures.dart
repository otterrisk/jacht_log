import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';

Event newEvent({
  String id = '123',
  EventSource source = EventSource.port,
  EventType type = EventType.start,
  DateTime? timestamp,
}) {
  final ts = timestamp ?? DateTime(2024, 7, 5);
  final json = {
    'id': id,
    'source': source.name,
    'type': type.name,
    'timestamp': ts.toIso8601String(),
  };
  return Event.fromJson(json);
}

Trip newTrip({
  String id = '123',
  DateTime? startTime,
  DateTime? endTime,
  List<Event> events = const [],
}) {
  final st = startTime ?? DateTime(2024, 7, 1);
  final et = endTime ?? DateTime(2024, 7, 14);
  final json = {
    'id': id,
    'startTime': st.toIso8601String(),
    'endTime': et.toIso8601String(),
    'events': events.map((e) => e.toJson()).toList(),
  };
  return Trip.fromJson(json);
}
