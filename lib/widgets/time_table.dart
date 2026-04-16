import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat_mode.dart';
import 'package:jacht_log/domain/boat_state.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/domain/trip_time_view.dart';
import 'package:jacht_log/l10n/l10n.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';
import 'package:jacht_log/presentation/extensions/time_counter_ext.dart';
import 'package:jacht_log/presentation/view_models/time_table_vm.dart';
import 'package:jacht_log/widgets/trip_ticker_mixin.dart';

class TimeTable extends StatefulWidget {
  final TripTimeBase times;
  final BoatState state;
  final Trip trip;

  const TimeTable({
    super.key,
    required this.times,
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
  bool get isActive => widget.trip.isActive;

  @override
  Duration get tickInterval => const Duration(seconds: 1);

  @override
  Widget build(BuildContext context) {
    final vm = TimeTableViewModel.create(
      times: widget.times,
      now: DateTime.now(),
    );
    final currentCounter = widget.state.mode.counter;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
          children: [
            for (final counter in TimeCounter.values) ...[
              _timeRow(
                counter.text(context),
                vm.values[counter]!,
                highlighted: counter == currentCounter && isActive,
              ),
            ],
            const TableRow(children: [Divider(), Divider()]),
            _timeRow(context.l10n.timeTableTotal, vm.total, bold: true),
          ],
        ),
      ),
    );
  }

  TableRow _timeRow(
    String label,
    Duration duration, {
    bool bold = false,
    bool highlighted = false,
  }) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;

    final backgroundColor = highlighted
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
        : null;

    return TableRow(
      decoration: BoxDecoration(color: backgroundColor),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Text(label, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
