import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/services/trip_storage.dart';

import '../domain/fixtures.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory tempDir;
  late TripStorage storage;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('jacht_log_trip_storage_test');
    storage = TripStorage();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      return tempDir.path;
    });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('TripStorage', () {
    test('upsert appends new trips and updates only matching ID', () async {
      final trip1 = newTrip(id: 'trip-1', startTime: DateTime(2026, 1, 10, 10));
      final trip2 = newTrip(id: 'trip-2', startTime: DateTime(2026, 1, 11, 10));
      final trip1Updated = newTrip(
        id: 'trip-1',
        startTime: DateTime(2026, 1, 10, 10),
        endTime: DateTime(2026, 1, 10, 13),
      );

      await storage.upsert(trip1);
      await storage.upsert(trip2);
      await storage.upsert(trip1Updated);

      final trips = await storage.loadAll();
      final reloadedTrip1 = trips.firstWhere((trip) => trip.id == 'trip-1');
      final reloadedTrip2 = trips.firstWhere((trip) => trip.id == 'trip-2');

      expect(trips.length, 2);
      expect(reloadedTrip1.endTime, DateTime(2026, 1, 10, 13));
      expect(reloadedTrip2.endTime, isNull);
    });

    test('loadAll ignores old single-object format', () async {
      final file = File('${tempDir.path}/trip.json');
      await file.writeAsString(
        jsonEncode(newTrip(id: 'legacy-trip', startTime: DateTime(2026, 2, 1)).toJson()),
      );

      final trips = await storage.loadAll();

      expect(trips, isEmpty);
    });

    test('load returns latest open trip when present', () async {
      final olderOpen = newTrip(id: 'open-older', startTime: DateTime(2026, 3, 1, 9));
      final latestOpen = newTrip(id: 'open-latest', startTime: DateTime(2026, 3, 2, 9));
      final endedTrip = newTrip(
        id: 'ended',
        startTime: DateTime(2026, 3, 1, 10),
        endTime: DateTime(2026, 3, 1, 12),
      );

      await storage.saveAll([olderOpen, endedTrip, latestOpen]);

      final activeTrip = await storage.load();

      expect(activeTrip.id, 'open-latest');
    });

    test('load returns latest ended trip when no open trip exists', () async {
      final olderEnded = newTrip(
        id: 'ended-older',
        startTime: DateTime(2026, 4, 1, 8),
        endTime: DateTime(2026, 4, 1, 9),
      );
      final latestEnded = newTrip(
        id: 'ended-latest',
        startTime: DateTime(2026, 4, 2, 8),
        endTime: DateTime(2026, 4, 2, 9),
      );

      await storage.saveAll([olderEnded, latestEnded]);

      final activeTrip = await storage.load();

      expect(activeTrip.id, 'ended-latest');
    });
  });
}
