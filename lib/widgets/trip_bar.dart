import 'package:flutter/material.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/extensions/date_time_ext.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';
import 'package:jacht_log/presentation/dialogs/date_time/show_date_time_dialog.dart';
import 'package:jacht_log/widgets/trip_control_button.dart';
import 'package:jacht_log/widgets/trip_ticker_mixin.dart';

const kDatePickerMarginYears = 10;

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

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(child: Center(child: _timeRangeWidget(trip))),
          TripControlButton(trip: trip),
        ],
      ),
    );
  }

  Widget _timeRangeWidget(Trip trip) {
    final start = trip.isStarted
        ? trip.startTime!.toTripBarDateTime()
        : "--:--";

    final end = trip.isActive
        ? DateTime.now().toTripBarDateTime(blink: true)
        : (trip.isFinished ? trip.endTime!.toTripBarDateTime() : "--:--");

    final firstEventTime = trip.events.isEmpty
        ? null
        : trip.events.first.timestamp;

    final lastEventTime = trip.events.isEmpty
        ? null
        : trip.events.last.timestamp;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _timeChip(
          text: start,
          highlighted: false,
          onTap: () async {
            if (!trip.isStarted) return;

            final result = await showDateTimeDialog(
              context: context,
              initialValue: trip.startTime!,
              firstDate: DateTime.now().subYears(kDatePickerMarginYears),
              lastDate: firstEventTime ?? DateTime.now(),
              title: 'Edit start time',
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
          highlighted: isActive,
          onTap: () async {
            if (!trip.isFinished) return;

            final result = await showDateTimeDialog(
              context: context,
              initialValue: trip.isFinished ? trip.endTime! : DateTime.now(),
              firstDate: lastEventTime ?? trip.startTime!,
              lastDate: DateTime.now().addYears(kDatePickerMarginYears),
              title: 'Edit end time',
            );

            if (result != null) {
              trip.setEndTime(result);
            }
          },
        ),
      ],
    );
  }

  Widget _timeChip({
    required String text,
    required bool highlighted,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: highlighted
          ? theme.colorScheme.primary.withValues(alpha: 0.1)
          : Colors.transparent,
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
