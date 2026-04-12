import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat_mode.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/trip_timer.dart';
import 'package:jacht_log/l10n/l10n.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';
import 'package:jacht_log/presentation/extensions/time_counter_ext.dart';

class TimeTable extends StatefulWidget {
  const TimeTable({super.key, required this.timer, required this.state});

  final TripTimer timer;
  final BoatState state;

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final liveDelta = now.difference(widget.timer.last).isNegative
        ? Duration.zero
        : now.difference(widget.timer.last);

    final currentCounter = widget.state.mode.counter;

    Duration value(TimeCounter counter) {
      final base = widget.timer.time[counter.index];

      if (counter == currentCounter) {
        return base + liveDelta;
      }
      return base;
    }

    final total = TimeCounter.values.fold<Duration>(
      Duration.zero,
      (sum, c) => sum + value(c),
    );

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
          children: [
            for (final counter in TimeCounter.values) ...[
              _timeRow(counter.text(context), value(counter)),
            ],
            const TableRow(children: [Divider(), Divider()]),
            _timeRow(context.l10n.timeTableTotal, total, bold: true),
          ],
        ),
      ),
    );
  }

  TableRow _timeRow(String label, Duration duration, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(label, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            duration.toTimeTableDuration(),
            textAlign: TextAlign.right,
            style: style,
          ),
        ),
      ],
    );
  }
}
