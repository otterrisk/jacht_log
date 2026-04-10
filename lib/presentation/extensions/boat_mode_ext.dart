import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat_mode.dart';
import 'package:jacht_log/l10n/app_localizations.dart';

extension BoatModeLabel on BoatMode {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (this) {
      BoatMode.stopped => l10n.boatModeStopped,
      BoatMode.sailing => l10n.boatModeSailing,
      BoatMode.motoring => l10n.boatModeMotoring,
      BoatMode.drifting => l10n.boatModeDrifting,
    };
  }
}
