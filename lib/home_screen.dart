import 'package:flutter/material.dart';
import 'package:jacht_log/controllers/trip_controller.dart';
import 'package:jacht_log/services/trip_storage.dart';
import 'package:jacht_log/widgets/boat_controls.dart';
import 'package:jacht_log/widgets/event_list.dart';
import 'package:jacht_log/widgets/time_table.dart';
import 'package:jacht_log/widgets/trip_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final TripController controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = TripController(TripStorage(), _scrollController);
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trip = controller.trip;
    final boat = controller.boat;

    if (trip == null || boat == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListenableBuilder(
      listenable: trip,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: [],
          ),
          body: Column(
            children: [
              TripBar(trip: trip),
              BoatControls(boat: boat, active: trip.active),
              EventList(trip: trip, scrollController: _scrollController),
              TimeTable(timer: boat.timer),
            ],
          ),
        );
      },
    );
  }
}
