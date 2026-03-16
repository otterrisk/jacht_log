import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/services/trip_storage.dart';

class BoatController extends ChangeNotifier {
  Boat? boat;
  final TripStorage storage;

  BoatController(this.storage) {
    _loadTrip();
  }

  void createTrip() {
    _detachTrip();
    final trip = Trip();
    _attachTrip(trip);
    boat = Boat(trip);
    notifyListeners();
  }

  Future<void> _loadTrip() async {
    final trip = await storage.load();
    _attachTrip(trip);
    boat = Boat(trip);
    notifyListeners();
  }

  void _attachTrip(Trip trip) {
    trip
      ..addListener(_saveTrip)
      ..addListener(_onTripChanged);
  }

  void _detachTrip() {
    if (boat != null) {
      boat!.trip
        ..removeListener(_saveTrip)
        ..removeListener(_onTripChanged);
    }
  }

  @override
  void dispose() {
    _detachTrip();
    super.dispose();
  }

  Future<void> _saveTrip() async {
    await storage.save(boat!.trip);
  }

  void _onTripChanged() {
    notifyListeners();
  }
}
