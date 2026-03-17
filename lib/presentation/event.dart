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
    return switch (this) {
      EventSource.engine => Icons.settings,
      EventSource.sail => Icons.sailing,
      EventSource.port => Icons.directions_boat,
      EventSource.anchor => Icons.anchor,
    };
  }
}

extension EventDescription on Event {
  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final map = {
      EventSource.port: {
        EventType.start: l10n.eventSourcePortEventTypeStart,
        EventType.stop: l10n.eventSourcePortEventTypeStop,
      },
      EventSource.anchor: {
        EventType.start: l10n.eventSourceAnchorEventTypeStart,
        EventType.stop: l10n.eventSourceAnchorEventTypeStop,
      },
      EventSource.engine: {
        EventType.start: l10n.eventSourceEngineEventTypeStart,
        EventType.stop: l10n.eventSourceEngineEventTypeStop,
      },
      EventSource.sail: {
        EventType.start: l10n.eventSourceSailEventTypeStart,
        EventType.stop: l10n.eventSourceSailEventTypeStop,
      },
    };

    return map[source]![type]!;
  }
}
