import 'package:flutter/material.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';
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

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(child: Center(child: _timeRangeWidget(trip))),
          IconButton(
            icon: Icon(trip.isActive ? Icons.stop : Icons.play_arrow),
            onPressed: trip.isActive ? trip.stop : trip.start,
          ),
        ],
      ),
    );
  }

  Widget _timeRangeWidget(Trip trip) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _timeChip(
          text: trip.isStarted ? trip.startTime!.toTripBarDateTime() : "--:--",
          onTap: () {
            // TODO: edit startTime
          },
        ),
        const SizedBox(width: 6),
        const Text("→"),
        const SizedBox(width: 6),
        _timeChip(
          text: trip.isActive
              ? DateTime.now().toTripBarDateTime(blink: true)
              : (trip.isFinished ? trip.endTime!.toTripBarDateTime() : "--:--"),
          onTap: () {
            // TODO: edit endTime
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
