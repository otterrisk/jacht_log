import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip_validator.dart';
import 'package:jacht_log/presentation/extensions/event_ext.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';

class EventTile extends StatelessWidget {
  final Event event;
  final List<ValidationIssue> issues;
  final Color background;
  final VoidCallback onTap;

  const EventTile({
    super.key,
    required this.event,
    required this.issues,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: background,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        child: Row(
          children: [
            Icon(event.source.icon, size: 20),
            const SizedBox(width: 8),
            Text(event.description(context)),
            const Spacer(),
            if (issues.any((i) => i.severity == Severity.error))
              Icon(Icons.error, color: Colors.red),
            if (issues.any((i) => i.severity == Severity.error))
              const SizedBox(width: 8),
            Text(
              event.timestamp.toEventListTimestamp(context),
              style: const TextStyle(
                color: Colors.grey,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
