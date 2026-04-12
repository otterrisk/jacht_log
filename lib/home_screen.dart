import 'package:flutter/material.dart';
import 'package:jacht_log/controllers/boat_controller.dart';
import 'package:jacht_log/domain/trip_validator.dart';
import 'package:jacht_log/l10n/l10n.dart';
import 'package:jacht_log/presentation/view_models/validation_vm.dart';
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
  late VoidCallback _listener;
  int _lastEventCount = 0;

  @override
  void initState() {
    super.initState();

    controller = BoatController(TripStorage());

    _listener = () {
      final eventCount = controller.boat?.trip.events.length ?? 0;

      setState(() {});

      if (eventCount != _lastEventCount) {
        _lastEventCount = eventCount;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_scrollController.hasClients) return;

          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        });
      }
    };

    controller.addListener(_listener);
  }

  @override
  void dispose() {
    controller.removeListener(_listener);
    controller.dispose();
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
      listenable: boat,
      builder: (context, child) {
        final trip = boat.trip;
        final validation = ValidationViewModel(TripValidator().validate(trip));
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: [
              ElevatedButton(
                onPressed: controller.createTrip,
                child: Text(context.l10n.newTripButton),
              ),
            ],
          ),
          body: Column(
            children: [
              TripBar(trip: trip),
              BoatControls(boat: boat, active: trip.active),
              EventList(
                trip: trip,
                validation: validation,
                scrollController: _scrollController,
              ),
              TimeTable(timer: boat.timer, state: boat.state, trip: trip),
            ],
          ),
        );
      },
    );
  }
}
