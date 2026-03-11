import 'package:jacht_log/boat.dart';

extension ModeLabel on Mode {
  String get label {
    switch (this) {
      case Mode.sailing:
        return "Under way, sailing";
      case Mode.motoring:
        return "Under way, motoring";
      case Mode.stopped:
        return "At rest";
      case Mode.idle:
        return "Idle";
      case Mode.afloat:
        return "Under way, afloat";
    }
  }
}

extension ModeTimeText on Mode {
  String get timeText {
    switch (this) {
      case Mode.sailing:
        return "Sailing time";
      case Mode.motoring:
        return "Motoring time";
      case Mode.stopped:
        return "Stop time";
      case Mode.idle:
        return "Idle time";
      case Mode.afloat:
        return "Afloat time";
    }
  }
}
