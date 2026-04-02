import 'package:jacht_log/domain/event.dart';

class AddEventResult {
  final DateTime timestamp;
  final EventType type;
  final EventSource source;

  AddEventResult({
    required this.timestamp,
    required this.type,
    required this.source,
  });
}
