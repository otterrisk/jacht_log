import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DateTimeFormatting on DateTime {
  String toEventListTimestamp(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat('EEE, HH:mm', locale).format(this);
  }

  String toTripBarDateTime({bool blink = false}) {
    final now = DateTime.now();
    final ms = now.millisecond;
    final sep = (blink && ms > 500) ? " " : ":";

    String time =
        "${hour.toString().padLeft(2, '0')}$sep${minute.toString().padLeft(2, '0')}";

    return "${DateFormat("dd.MM.yyyy").format(this)} $time";
  }
}

extension DurationFormatting on Duration {
  String toTimeTableDuration() {
    final hours = inHours;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;
    return "${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s";
  }
}
