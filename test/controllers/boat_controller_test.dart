import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/controllers/boat_controller.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/services/trip_storage.dart';

import '../domain/fixtures.dart';

class FakeTripStorage extends TripStorage {
  final List<Trip> upsertedTrips = [];
  Trip tripToLoad;
  final List<Trip> allTrips;

  FakeTripStorage({required this.tripToLoad, List<Trip>? allTrips})
    : allTrips = allTrips ?? [];

  @override
  Future<List<Trip>> loadAll() async => List<Trip>.from(allTrips);

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

    test('loadTrips returns trips sorted by startTime descending, nulls last', () async {
      final newest = newTrip(id: 'new', startTime: DateTime(2026, 2, 1, 12));
      final oldest = newTrip(id: 'old', startTime: DateTime(2026, 1, 1, 12));
      final noStart = newTrip(id: 'nostart', startTime: null);
      final storage = FakeTripStorage(
        tripToLoad: oldest,
        allTrips: [oldest, noStart, newest],
      );
      final controller = BoatController(storage);

      await Future<void>.delayed(Duration.zero);
      final list = await controller.loadTrips();

      expect(list.map((t) => t.id), ['new', 'old', 'nostart']);
    });

    test('selectTrip switches active trip; unknown id is no-op', () async {
      final a = newTrip(id: 'trip-a', startTime: DateTime(2026, 1, 10, 10));
      final b = newTrip(id: 'trip-b', startTime: DateTime(2026, 1, 11, 10));
      final storage = FakeTripStorage(tripToLoad: a, allTrips: [a, b]);
      final controller = BoatController(storage);

      await Future<void>.delayed(Duration.zero);
      expect(controller.boat!.trip.id, 'trip-a');

      await controller.selectTrip('trip-b');
      expect(controller.boat!.trip.id, 'trip-b');

      await controller.selectTrip('missing');
      expect(controller.boat!.trip.id, 'trip-b');
    });
  });
}
