import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jacht_log/domain/trip.dart';

class TripBar extends StatefulWidget {
  final Trip trip;

  const TripBar({super.key, required this.trip});

  @override
  State<TripBar> createState() => _TripBarState();
}

class _TripBarState extends State<TripBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.trip.addListener(_tripChanged);
    _updateTimer();
  }

  @override
  void dispose() {
    widget.trip.removeListener(_tripChanged);
    _timer?.cancel();
    super.dispose();
  }

  void _tripChanged() {
    _updateTimer();
    setState(() {});
  }

  void _updateTimer() {
    _timer?.cancel();

    if (widget.trip.active) {
      _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
        setState(() {});
      });
    }
  }

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
    final start = _fmt(trip.startTime);

    final end = trip.active
        ? _fmt(DateTime.now(), blink: true)
        : (trip.endTime != null ? _fmt(trip.endTime!) : "--:--");

    return "$start → $end";
  }

  String _fmt(DateTime t, {bool blink = false}) {
    final now = DateTime.now();

    final ms = now.millisecond;
    final sep = (blink && ms > 500) ? " " : ":";

    String time =
        "${t.hour.toString().padLeft(2, '0')}$sep${t.minute.toString().padLeft(2, '0')}";

    if (t.year != now.year) {
      return "${DateFormat("dd.MM.yyyy").format(t)} $time";
    }

    if (t.day != now.day || t.month != now.month) {
      return "${DateFormat("dd.MM").format(t)} $time";
    }

    return time;
  }
}
