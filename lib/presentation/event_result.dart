import 'package:jacht_log/domain/event.dart';

class EventResult {
  final DateTime timestamp;
  final EventSource source;
  final EventType type;

  EventResult({
    required this.timestamp,
    required this.source,
    required this.type,
  });
}
