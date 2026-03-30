import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/presentation/event.dart';

class EventTile extends StatelessWidget {
  final Event event;
  final Color background;
  final VoidCallback onTap;

  const EventTile({
    super.key,
    required this.event,
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
            Text(
              _formatTimestamp(context, event.timestamp),
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

  String _formatTimestamp(BuildContext context, DateTime t) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('EEE, HH:mm', locale).format(t);
  }
}
