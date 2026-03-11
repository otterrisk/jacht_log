import 'package:jacht_log/boat.dart';

extension ModeLabel on Mode {
  String get label {
    switch (this) {
      case Mode.sailing:
        return "Sailing";
      case Mode.motoring:
        return "Motoring";
      case Mode.stopped:
        return "Stopped";
      case Mode.idle:
        return "Idle";
      case Mode.afloat:
        return "Afloat";
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
