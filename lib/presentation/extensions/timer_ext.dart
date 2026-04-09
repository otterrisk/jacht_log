import 'package:flutter/material.dart';
import 'package:jacht_log/domain/timer.dart';
import 'package:jacht_log/l10n/app_localizations.dart';

extension TimeCounterText on TimeCounter {
  String text(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (this) {
      TimeCounter.sailing => l10n.timeCounterSailing,
      TimeCounter.motoring => l10n.timeCounterMotoring,
      TimeCounter.stopped => l10n.timeCounterStopped,
    };
  }
}
