import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/widgets/event_editor_dialog.dart';
import 'package:jacht_log/widgets/event_tile.dart';

class EventList extends StatelessWidget {
  final Trip trip;
  final ScrollController scrollController;

  const EventList({
    super.key,
    required this.trip,
    required this.scrollController,
  });

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
    return Dismissible(
      key: ValueKey(event.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _onDelete(context, event),

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      child: EventTile(
        event: event,
        background: background,
        onTap: () => _editEventDetails(context, event),
      ),
    );
  }

  void _onDelete(BuildContext context, Event event) {
    final removedEvent = event;

    trip.removeEvent(event.id);

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 4),
        content: Text('Event deleted'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            _undoDelete(removedEvent);
          },
        ),
      ),
    );
  }

  void _undoDelete(Event event) {
    trip.addEvent(event);
  }

  Future<void> _editEventDetails(BuildContext context, Event event) async {
    final updatedEvent = await showDialog<Event>(
      context: context,
      builder: (_) => EventEditorDialog(
        event: event,
        minTime: trip.startTime,
        maxTime: trip.endTime ?? DateTime.now(),
      ),
    );

    if (updatedEvent == null) return;

    trip.updateEventTimestamp(updatedEvent.id, updatedEvent.timestamp);
  }
}
