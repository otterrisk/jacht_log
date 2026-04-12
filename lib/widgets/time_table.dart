import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat_mode.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/domain/trip_timer.dart';
import 'package:jacht_log/l10n/l10n.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';
import 'package:jacht_log/presentation/extensions/time_counter_ext.dart';
import 'package:jacht_log/widgets/trip_ticker_mixin.dart';

class TimeTable extends StatefulWidget {
  final TripTimer timer;
  final BoatState state;
  final Trip trip;

  const TimeTable({
    super.key,
    required this.timer,
    required this.state,
    required this.trip,
  });

  @override
  State<TimeTable> createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> with TripTickerMixin {
  @override
  Listenable get trip => widget.trip;

  @override
  bool get isActive => widget.trip.active;

  @override
  Duration get tickInterval => const Duration(seconds: 1);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final liveDelta = now.difference(widget.timer.last).isNegative
        ? Duration.zero
        : now.difference(widget.timer.last);

    final currentCounter = widget.state.mode.counter;

    Duration value(TimeCounter counter) {
      final base = widget.timer.time[counter.index];

      if (counter == currentCounter && isActive) {
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
