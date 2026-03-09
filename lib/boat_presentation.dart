import 'package:hello/boat.dart';

extension ModeLabel on Mode {
  String get label {
    switch (this) {
      case Mode.sailing:
        return "Sailing";
      case Mode.motoring:
        return "Motoring";
      case Mode.stopped:
        return "Stopped";
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
    }
  }
}
