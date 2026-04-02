import 'package:flutter/material.dart';
import 'package:jacht_log/domain/timer.dart';
import 'package:jacht_log/l10n/l10n.dart';
import 'package:jacht_log/presentation/formatting.dart';
import 'package:jacht_log/presentation/timer.dart';

class TimeTable extends StatelessWidget {
  const TimeTable({super.key, required this.timer});

  final Timer timer;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
          children: [
            for (final counter in TimeCounter.values) ...[
              _timeRow(counter.text(context), timer.time[counter.index]),
            ],
            const TableRow(children: [Divider(), Divider()]),
            _timeRow(
              context.l10n.timeTableTotal,
              timer.time.fold(Duration.zero, (sum, d) => sum + d),
              bold: true,
            ),
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
