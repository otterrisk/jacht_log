import 'dart:convert';
import 'dart:io';
import 'package:jacht_log/domain/trip.dart';
import 'package:path_provider/path_provider.dart';

class TripStorage {
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/trip.json');
  }

  Future<void> save(Trip trip) async {
    await upsert(trip);
  }

  Future<void> saveAll(List<Trip> trips) async {
    final file = await _getFile();
    await file.writeAsString(jsonEncode(trips.map((trip) => trip.toJson()).toList()));
  }

  Future<void> upsert(Trip trip) async {
    final trips = await loadAll();
    final index = trips.indexWhere((existing) => existing.id == trip.id);
    if (index == -1) {
      trips.add(trip);
    } else {
      trips[index] = trip;
    }
    await saveAll(trips);
  }

  Future<List<Trip>> loadAll() async {
    try {
      final file = await _getFile();

      if (!await file.exists()) {
        return [];
      }

      final json = jsonDecode(await file.readAsString());
      if (json is! List) {
        return [];
      }

      return json
          .whereType<Map<String, dynamic>>()
          .map(Trip.fromJson)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<Trip> load() async {
    final trips = await loadAll();
    final latestOpen = trips
        .where((trip) => !trip.isFinished)
        .fold<Trip?>(null, _selectLatestOpenTrip);
    if (latestOpen != null) {
      return latestOpen;
    }

    final latestEnded = trips
        .where((trip) => trip.isFinished)
        .fold<Trip?>(null, _selectLatestEndedTrip);
    if (latestEnded != null) {
      return latestEnded;
    }

    return Trip();
  }

  Trip _selectLatestOpenTrip(Trip? current, Trip candidate) {
    if (current == null) {
      return candidate;
    }

    final candidateStart = candidate.startTime;
    final currentStart = current.startTime;
    if (candidateStart == null) {
      return current;
    }
    if (currentStart == null || candidateStart.isAfter(currentStart)) {
      return candidate;
    }
    return current;
  }

  Trip _selectLatestEndedTrip(Trip? current, Trip candidate) {
    if (current == null) {
      return candidate;
    }

    final candidateEnd = candidate.endTime!;
    final currentEnd = current.endTime!;
    if (candidateEnd.isAfter(currentEnd)) {
      return candidate;
    }
    if (candidateEnd.isAtSameMomentAs(currentEnd)) {
      final candidateStart = candidate.startTime;
      final currentStart = current.startTime;
      if (candidateStart != null &&
          (currentStart == null || candidateStart.isAfter(currentStart))) {
        return candidate;
      }
    }
    return current;
  }
}
