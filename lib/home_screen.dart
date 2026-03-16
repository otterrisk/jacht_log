import 'package:flutter/material.dart';
import 'package:jacht_log/controllers/boat_controller.dart';
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
  late final BoatController controller;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = BoatController(TripStorage(), _scrollController);
    controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final boat = controller.boat;

    if (boat == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListenableBuilder(
      listenable: boat.trip,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: [
              ElevatedButton(
                onPressed: boat.trip.reset,
                child: Text("New trip"),
              ),
            ],
          ),
          body: Column(
            children: [
              TripBar(trip: boat.trip),
              BoatControls(boat: boat, active: boat.trip.active),
              EventList(trip: boat.trip, scrollController: _scrollController),
              TimeTable(timer: boat.timer),
            ],
          ),
        );
      },
    );
  }
}
