import 'package:flutter/material.dart';
import 'package:jacht_log/controllers/boat_controller.dart';
import 'package:jacht_log/domain/trip_validator.dart';
import 'package:jacht_log/l10n/l10n.dart';
import 'package:jacht_log/presentation/extensions/formatting_ext.dart';
import 'package:jacht_log/presentation/view_models/validation_vm.dart';
import 'package:jacht_log/services/trip_storage.dart';
import 'package:jacht_log/widgets/boat_controls.dart';
import 'package:jacht_log/widgets/event_list.dart';
import 'package:jacht_log/widgets/time_table.dart';
import 'package:jacht_log/widgets/trip_bar.dart';

enum _HomeMenuAction { newTrip, loadTrip }

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

  Future<void> _showLoadTripDialog(BuildContext context) async {
    final trips = await controller.loadTrips();
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(l10n.selectTripTitle),
          content: SizedBox(
            width: double.maxFinite,
            height: 360,
            child: trips.isEmpty
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Text(l10n.noTripsMessage),
                  )
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      final title = trip.startTime != null
                          ? trip.startTime!.toTripBarDateTime()
                          : l10n.tripListNotStarted;
                      final String? subtitle;
                      if (trip.isActive) {
                        subtitle = l10n.tripListTripActive;
                      } else if (trip.isFinished && trip.endTime != null) {
                        subtitle = trip.endTime!.toTripBarDateTime();
                      } else {
                        subtitle = null;
                      }
                      return ListTile(
                        title: Text(title),
                        subtitle: subtitle != null ? Text(subtitle) : null,
                        onTap: () async {
                          Navigator.of(dialogContext).pop();
                          await controller.selectTrip(trip.id);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                MaterialLocalizations.of(dialogContext).cancelButtonLabel,
              ),
            ),
          ],
        );
      },
    );
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
              PopupMenuButton<_HomeMenuAction>(
                icon: const Icon(Icons.menu),
                onSelected: (action) async {
                  switch (action) {
                    case _HomeMenuAction.newTrip:
                      await controller.createTrip();
                    case _HomeMenuAction.loadTrip:
                      await _showLoadTripDialog(context);
                  }
                },
                itemBuilder: (menuContext) => [
                  PopupMenuItem(
                    value: _HomeMenuAction.newTrip,
                    child: Text(menuContext.l10n.newTripMenuItem),
                  ),
                  PopupMenuItem(
                    value: _HomeMenuAction.loadTrip,
                    child: Text(menuContext.l10n.loadTripMenuItem),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              TripBar(trip: trip),
              BoatControls(boat: boat, active: trip.isActive),
              EventList(
                trip: trip,
                validation: validation,
                scrollController: _scrollController,
              ),
              TimeTable(times: boat.times, state: boat.state, trip: trip),
            ],
          ),
        );
      },
    );
  }
}
