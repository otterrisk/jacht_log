import 'package:uuid/uuid.dart';

enum EventSource { port, engine, sail, anchor }

enum EventType { start, stop }

class Event {
  final String id;
  final EventSource source;
  final EventType type;
  final DateTime timestamp;

  Event._({
    required this.id,
    required this.source,
    required this.type,
    required this.timestamp,
  });

  factory Event({required EventSource source, required EventType type}) {
    return Event._(
      id: const Uuid().v4(),
      source: source,
      type: type,
      timestamp: DateTime.now(),
    );
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event._(
      id: json['id'],
      source: EventSource.values.byName(json['source']),
      type: EventType.values.byName(json['type']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source.name,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Event && other.id == id;

  @override
  int get hashCode => id.hashCode;

  Event copyWith({EventSource? source, EventType? type, DateTime? timestamp}) {
    return Event._(
      id: id,
      source: source ?? this.source,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() =>
      'Event(id: $id, source: $source, type: $type, timestamp: $timestamp)';
}
