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

  Future<void> createTrip() async {
    _detachTrip();
    final trip = Trip.started();
    _attachTrip(trip);
    boat = Boat(trip);
    await storage.upsert(trip);
    notifyListeners();
  }

  Future<List<Trip>> loadTrips() async {
    final trips = await storage.loadAll();
    final withStart = trips.where((t) => t.startTime != null).toList();
    final withoutStart = trips.where((t) => t.startTime == null).toList();
    withStart.sort((a, b) => b.startTime!.compareTo(a.startTime!));
    return [...withStart, ...withoutStart];
  }

  Future<void> selectTrip(String id) async {
    final trip = await storage.loadById(id);
    if (trip == null) {
      return;
    }
    _detachTrip();
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
    await storage.upsert(boat!.trip);
  }

  void _onTripChanged() {
    notifyListeners();
  }
}
