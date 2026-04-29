import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/controllers/boat_controller.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/services/trip_storage.dart';

class FakeTripStorage extends TripStorage {
  final List<Trip> upsertedTrips = [];
  Trip tripToLoad;

  FakeTripStorage({required this.tripToLoad});

  @override
  Future<Trip> load() async => tripToLoad;

  @override
  Future<void> upsert(Trip trip) async {
    upsertedTrips.add(trip);
  }
}

void main() {
  group('BoatController', () {
    test('createTrip persists started trip immediately', () async {
      final storage = FakeTripStorage(tripToLoad: Trip());
      final controller = BoatController(storage);

      await Future<void>.delayed(Duration.zero);
      await controller.createTrip();

      expect(controller.boat, isNotNull);
      expect(controller.boat!.trip.isStarted, isTrue);
      expect(storage.upsertedTrips, isNotEmpty);
      expect(storage.upsertedTrips.last.id, controller.boat!.trip.id);
    });
  });
}
