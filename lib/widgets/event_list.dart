import 'package:flutter/material.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/domain/trip_validator.dart';
import 'package:jacht_log/presentation/actions/events/add_event.dart';
import 'package:jacht_log/presentation/actions/events/edit_event_timestamp.dart';
import 'package:jacht_log/presentation/view_models/validation_vm.dart';
import 'package:jacht_log/widgets/event_tile.dart';

class EventList extends StatelessWidget {
  final Trip trip;
  final ValidationViewModel validation;
  final ScrollController scrollController;

  const EventList({
    super.key,
    required this.trip,
    required this.validation,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Text(
                    "Events",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: trip.canAddEvent
                        ? () => addEvent(context: context, trip: trip)
                        : null,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: trip.events.length,
                itemBuilder: (context, index) {
                  final event = trip.events[index];
                  final issues = validation.index[event.id] ?? [];
                  final background = index.isEven
                      ? Theme.of(context).colorScheme.surfaceContainerHighest
                      : Colors.transparent;

                  return eventRow(context, event, issues, background);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventRow(
    BuildContext context,
    Event event,
    List<ValidationIssue> issues,
    Color background,
  ) {
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
        issues: issues,
        background: background,
        onTap: () =>
            editEventTimestamp(context: context, event: event, trip: trip),
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
}
