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
  bool get isActive => widget.trip.active;

  @override
  Duration get tickInterval => const Duration(milliseconds: 500);

  @override
  Widget build(BuildContext context) {
    final trip = widget.trip;

    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(child: Center(child: Text(_timeRange(trip)))),
          IconButton(
            icon: Icon(trip.active ? Icons.stop : Icons.play_arrow),
            onPressed: trip.active ? trip.stop : trip.start,
          ),
        ],
      ),
    );
  }

  String _timeRange(Trip trip) {
    final start = trip.started ? trip.startTime?.toTripBarDateTime() : "--:--";

    final end = trip.active
        ? DateTime.now().toTripBarDateTime(blink: true)
        : (trip.finished ? trip.endTime?.toTripBarDateTime() : "--:--");

    return "$start → $end";
  }
}
