enum EventSource { port, engine, sail, anchor }

enum EventType { start, stop }

class Event {
  final EventSource source;
  final EventType type;
  final DateTime timestamp;
  Event({required this.source, required this.type, required this.timestamp});

  Map<String, dynamic> toJson() => {
    'source': source.name,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      source: EventSource.values.byName(json['source']),
      type: EventType.values.byName(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
