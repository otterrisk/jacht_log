import 'package:flutter/widgets.dart';
import 'package:jacht_log/l10n/app_localizations.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
