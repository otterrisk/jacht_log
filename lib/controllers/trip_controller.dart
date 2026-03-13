import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/services/trip_storage.dart';

class TripController extends ChangeNotifier {
  Trip? trip;
  Boat? boat;

  final TripStorage storage;
  final ScrollController scrollController;

  TripController(this.storage, this.scrollController) {
    createTrip();
  }

  void createTrip() {
    trip = Trip();
    boat = Boat(trip!);

    trip?.addListener(_saveTrip);
    trip?.addListener(_onTripChanged);
  }

  Future<void> _loadTrip() async {
    trip = await storage.load();
    boat = Boat(trip!);

    trip?.addListener(_saveTrip);
    trip?.addListener(_onTripChanged);
  }

  @override
  void dispose() {
    trip?.removeListener(_onTripChanged);
    trip?.removeListener(_saveTrip);
    super.dispose();
  }

  void _saveTrip() {
    storage.save(trip!);
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
