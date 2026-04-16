import 'package:flutter/material.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/extensions/trip_status_ext.dart';

class TripControlButton extends StatelessWidget {
  final Trip trip;

  const TripControlButton({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final status = trip.status;

    return IconButton(
      icon: Icon(_iconFor(status)),
      onPressed: _actionFor(status),
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

  VoidCallback? _actionFor(TripStatus status) {
    switch (status) {
      case TripStatus.notStarted:
        return trip.start;
      case TripStatus.active:
        return trip.stop;
      case TripStatus.finished:
        return null;
    }
  }
}
