import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/l10n/app_localizations.dart';

extension EventSourceLabel on EventSource {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (this) {
      EventSource.port => l10n.eventSourcePort,
      EventSource.anchor => l10n.eventSourceAnchor,
      EventSource.engine => l10n.eventSourceEngine,
      EventSource.sail => l10n.eventSourceSail,
    };
  }
}

extension EventSourceIcon on EventSource {
  IconData get icon {
    switch (this) {
      case EventSource.engine:
        return Icons.settings;
      case EventSource.sail:
        return Icons.sailing;
      case EventSource.port:
        return Icons.directions_boat;
      case EventSource.anchor:
        return Icons.anchor;
    }
  }
}

const Map<(EventSource, EventType), String> eventDescriptions = {
  (EventSource.port, EventType.start): "Moored",
  (EventSource.port, EventType.stop): "Cast off",

  (EventSource.anchor, EventType.start): "Anchor casted",
  (EventSource.anchor, EventType.stop): "Anchor weighed",

  (EventSource.engine, EventType.start): "Engine started",
  (EventSource.engine, EventType.stop): "Engine stopped",

  (EventSource.sail, EventType.start): "Sail hoisted",
  (EventSource.sail, EventType.stop): "Sail lowered",
};

extension EventDescription on Event {
  String get description => eventDescriptions[(source, type)]!;
}
