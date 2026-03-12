import 'package:flutter/material.dart';
import 'package:jacht_log/domain/boat.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/domain/mode.dart';
import 'package:jacht_log/domain/trip.dart';
import 'package:jacht_log/presentation/event.dart';
import 'package:jacht_log/presentation/mode.dart';
import 'package:jacht_log/services/trip_storage.dart';
import 'package:jacht_log/widgets/boat_controls.dart';
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
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: trip.events.length,
                  itemBuilder: (context, index) {
                    final event = trip.events[index];
                    final background = index.isEven
                        ? Theme.of(context).colorScheme.surfaceContainerHighest
                        : Colors.transparent;

                    return eventRow(event, background);
                  },
                ),
              ),
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                    },
                    children: [
                      for (final mode in Mode.values) ...[
                        _timeRow(mode.timeText, boat.time[mode.index]),
                      ],
                      const TableRow(children: [Divider(), Divider()]),
                      _timeRow(
                        "Total",
                        boat.time.fold(Duration.zero, (sum, d) => sum + d),
                        bold: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  TableRow _timeRow(String label, Duration time, {bool bold = false}) {
    final style = bold ? const TextStyle(fontWeight: FontWeight.bold) : null;

    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(label, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            _formatDuration(time),
            textAlign: TextAlign.right,
            style: style,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    return "${hours}h ${minutes.toString().padLeft(2, '0')}m ${seconds.toString().padLeft(2, '0')}s";
  }

  Widget eventRow(Event event, Color background) {
    return Container(
      color: background,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        children: [
          Icon(event.source.icon, size: 20),
          const SizedBox(width: 8),

          Text(event.description),

          const Spacer(),

          Text(
            _formatTimestamp(event.timestamp),
            style: const TextStyle(
              color: Colors.grey,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:"
        "${t.minute.toString().padLeft(2, '0')}";
  }
}
