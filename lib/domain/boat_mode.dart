import 'package:jacht_log/domain/trip_timer.dart';

enum BoatMode { stopped, sailing, motoring, drifting }

extension BoatModeCounter on BoatMode {
  TimeCounter get counter => switch (this) {
    BoatMode.stopped => TimeCounter.stopped,
    BoatMode.sailing => TimeCounter.sailing,
    BoatMode.drifting => TimeCounter.sailing,
    BoatMode.motoring => TimeCounter.motoring,
  };
}
