import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/trip.dart';

enum ValidationCode { duplicateStart, duplicateStop, invalidFinalState }

enum Severity { warning, error }

class ValidationIssue {
  final ValidationCode code;
  final Severity severity;
  final Event event;
  final Event? relatedEvent;

  ValidationIssue({
    required this.code,
    required this.severity,
    required this.event,
    this.relatedEvent,
  });

  @override
  String toString() =>
      'ValidationIssue(code: $code, severity: $severity, event: ${event.id})';
}

class TripValidator {
  List<ValidationIssue> validate(Trip trip) {
    final events = List<Event>.from(trip.events)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return [..._validatePerSourceSequence(events)];
  }

  List<ValidationIssue> _validatePerSourceSequence(List<Event> events) {
    final issues = <ValidationIssue>[];

    final eventsBySource = <EventSource, List<Event>>{};
    for (final e in events) {
      eventsBySource.putIfAbsent(e.source, () => []).add(e);
    }

    for (final entry in eventsBySource.entries) {
      issues.addAll(_validateSingleSource(entry.key, entry.value));
    }

    return issues;
  }

  List<ValidationIssue> _validateSingleSource(
    EventSource source,
    List<Event> events,
  ) {
    assert(events.every((e) => e.source == source));

    final issues = <ValidationIssue>[];

    final isInitiallyOn = BoatState.initial().isOn(source);

    EventType expectedType = isInitiallyOn ? EventType.stop : EventType.start;

    Event? previous;

    for (final current in events) {
      if (current.type != expectedType) {
        issues.add(
          ValidationIssue(
            code: current.type == EventType.start
                ? ValidationCode.duplicateStart
                : ValidationCode.duplicateStop,
            severity: Severity.error,
            event: current,
            relatedEvent: previous,
          ),
        );
      }

      expectedType = current.type == EventType.start
          ? EventType.stop
          : EventType.start;

      previous = current;
    }

    final endsOn = expectedType == EventType.stop;
    final shouldEndOn = BoatState.initial().isOn(source);

    if (endsOn != shouldEndOn && previous != null) {
      issues.add(
        ValidationIssue(
          code: ValidationCode.invalidFinalState,
          severity: Severity.warning,
          event: previous,
        ),
      );
    }

    return issues;
  }
}
