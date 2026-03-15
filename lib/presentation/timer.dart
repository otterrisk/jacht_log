import 'package:jacht_log/domain/timer.dart';

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
