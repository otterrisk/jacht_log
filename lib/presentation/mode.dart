import 'package:jacht_log/domain/mode.dart';

extension BoatModeLabel on BoatMode {
  String get label {
    switch (this) {
      case BoatMode.sailing:
        return "Under way, sailing";
      case BoatMode.motoring:
        return "Under way, motoring";
      case BoatMode.stopped:
        return "At rest";
      case BoatMode.afloat:
        return "Under way, afloat";
    }
  }
}
