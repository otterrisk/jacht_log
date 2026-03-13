import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/services/trip_storage.dart';
import 'package:jacht_log/widgets/boat_controls.dart';
import 'package:jacht_log/widgets/event_list.dart';
import 'package:jacht_log/widgets/time_table.dart';
import 'package:jacht_log/widgets/trip_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TripStorage storage = TripStorage();

  Trip? _trip;
  Boat? _boat;

  Trip get trip => _trip!;
  Boat get boat => _boat!;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    createTrip();
    //_loadTrip();
  }

  void createTrip() {
    final trip = Trip();
    final boat = Boat(trip);

    trip.addListener(_saveTrip);
    trip.addListener(_onTripChanged);
    setState(() {
      _trip = trip;
      _boat = boat;
    });
  }

  Future<void> _loadTrip() async {
    final trip = await storage.load();
    final boat = Boat(trip);

    trip.addListener(_saveTrip);
    trip.addListener(_onTripChanged);

    setState(() {
      _trip = trip;
      _boat = boat;
    });
  }

  void _saveTrip() {
    storage.save(trip);
  }

  @override
  void dispose() {
    trip.removeListener(_onTripChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onTripChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    if (_trip == null || _boat == null) {
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
              BoatControls(boat: boat, trip: trip),
              EventList(trip: trip, scrollController: _scrollController),
              TimeTable(boat: boat),
            ],
          ),
        );
      },
    );
  }
}
