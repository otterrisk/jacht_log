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

extension TimeCounterText on TimeCounter {
  String get text {
    switch (this) {
      case TimeCounter.sailing:
        return "Sailing time";
      case TimeCounter.motoring:
        return "Motoring time";
      case TimeCounter.stopped:
        return "Stop time";
    }
  }
}
