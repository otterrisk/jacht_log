import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/event.dart';

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.trip,
    required this.scrollController,
  });

  final Trip trip;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: trip.events.length,
        itemBuilder: (context, index) {
          final event = trip.events[index];
          final background = index.isEven
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : Colors.transparent;

          return eventRow(context, event, background);
        },
      ),
    );
  }

  Widget eventRow(BuildContext context, Event event, Color background) {
    return Container(
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
    );
  }

  String _formatTimestamp(BuildContext context, DateTime t) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('EEE, HH:mm', locale).format(t);
  }
}
