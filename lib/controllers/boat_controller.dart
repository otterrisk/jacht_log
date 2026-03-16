import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/services/trip_storage.dart';

class BoatController extends ChangeNotifier {
  Boat? boat;

  final TripStorage storage;
  final ScrollController scrollController;

  BoatController(this.storage, this.scrollController) {
    _loadTrip();
  }

  void createTrip() {
    final trip = Trip();
    trip.addListener(_saveTrip);
    trip.addListener(_onTripChanged);
    boat = Boat(trip);
    notifyListeners();
  }

  Future<void> _loadTrip() async {
    final trip = await storage.load();
    trip.addListener(_saveTrip);
    trip.addListener(_onTripChanged);
    boat = Boat(trip);
    notifyListeners();
  }

  @override
  void dispose() {
    boat?.trip.removeListener(_onTripChanged);
    boat?.trip.removeListener(_saveTrip);
    super.dispose();
  }

  void _saveTrip() {
    storage.save(boat!.trip);
  }

  void _onTripChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
