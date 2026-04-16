import 'package:flutter/material.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';
import 'package:jacht_log/presentation/extensions/trip_status_ext.dart';
import 'package:jacht_log/widgets/date_time_picker_dialog.dart';
import 'package:jacht_log/widgets/trip_ticker_mixin.dart';

class TripBar extends StatefulWidget {
  final Trip trip;

  const TripBar({super.key, required this.trip});

  @override
  State<TripBar> createState() => _TripBarState();
}

class _TripBarState extends State<TripBar> with TripTickerMixin {
  @override
  Listenable get trip => widget.trip;

  @override
  bool get isActive => widget.trip.isActive;

  @override
  Duration get tickInterval => const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;
    final status = trip.status;

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(child: Center(child: _timeRangeWidget(trip))),
          IconButton(
            icon: Icon(_iconFor(status)),
            onPressed: _actionFor(status, trip),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(TripStatus status) {
    switch (status) {
      case TripStatus.notStarted:
        return Icons.play_arrow;
      case TripStatus.active:
      case TripStatus.finished:
        return Icons.stop;
    }
  }

  VoidCallback? _actionFor(TripStatus status, Trip trip) {
    switch (status) {
      case TripStatus.notStarted:
        return trip.start;
      case TripStatus.active:
        return trip.stop;
      case TripStatus.finished:
        return null;
    }
  }

  Widget _timeRangeWidget(Trip trip) {
    final start = trip.isStarted
        ? trip.startTime!.toTripBarDateTime()
        : "--:--";

    final end = trip.isActive
        ? DateTime.now().toTripBarDateTime(blink: true)
        : (trip.isFinished ? trip.endTime!.toTripBarDateTime() : "--:--");

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _timeChip(
          text: start,
          onTap: () async {
            if (!trip.isStarted) return;

            final result = await showDateTimePickerDialog(
              context: context,
              value: trip.startTime!,
              firstDate: DateTime(2000),
              lastDate:
                  trip.endTime ?? DateTime.now().add(const Duration(days: 365)),
            );

            if (result != null) {
              trip.setStartTime(result);
            }
          },
        ),

        const SizedBox(width: 6),
        const Text("→"),
        const SizedBox(width: 6),

        _timeChip(
          text: end,
          onTap: () async {
            if (!trip.isFinished) return;

            final result = await showDateTimePickerDialog(
              context: context,
              value: trip.isFinished ? trip.endTime! : DateTime.now(),

              firstDate: trip.startTime!,
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );

            if (result != null) {
              trip.setEndTime(result);
            }
          },
        ),
      ],
    );
  }

  Widget _timeChip({required String text, required VoidCallback onTap}) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(text, style: theme.textTheme.bodyMedium),
        ),
      ),
    );
  }
}
