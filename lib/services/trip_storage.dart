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
    final file = await _getFile();
    await file.writeAsString(jsonEncode(trip.toJson()));
  }

  Future<Trip> load() async {
    try {
      final file = await _getFile();

      if (!await file.exists()) {
        return Trip();
      }

      final json = jsonDecode(await file.readAsString());
      return Trip.fromJson(json);
    } catch (e) {
      return Trip();
    }
  }
}
