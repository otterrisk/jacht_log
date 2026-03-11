import 'package:flutter/material.dart';

import 'package:jacht_log/boat.dart';
import 'package:jacht_log/boat_presentation.dart';
import 'package:jacht_log/event.dart';
import 'package:jacht_log/event_presentation.dart';
import 'package:jacht_log/trip.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jacht Log',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const MyHomePage(title: 'Jacht Log'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
            actions: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    "${_formatTimestamp(trip.startTime)} - ${trip.endTime == null ? "-" : _formatTimestamp(trip.endTime!)}",
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: trip.active ? trip.stop : trip.start,
                child: Text(trip.active ? "Finish trip" : "Start trip"),
              ),
            ],
          ),
          body: Column(
            children: [
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
          Icon(_iconForSource(event.source), size: 20),
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

  IconData _iconForSource(EventSource source) {
    switch (source) {
      case EventSource.engine:
        return Icons.settings;
      case EventSource.sail:
        return Icons.sailing;
      case EventSource.port:
        return Icons.directions_boat;
      case EventSource.anchor:
        return Icons.anchor;
    }
  }
}

class BoatControls extends StatelessWidget {
  const BoatControls({super.key, required this.boat, required this.trip});

  final Boat boat;
  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 3,
            children: [
              SwitchListTile(
                title: Text(EventSource.port.label),
                value: boat.isOn(EventSource.port),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.port)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.engine.label),
                value: boat.isOn(EventSource.engine),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.engine)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.anchor.label),
                value: boat.isOn(EventSource.anchor),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.anchor)
                    : null,
              ),
              SwitchListTile(
                title: Text(EventSource.sail.label),
                value: boat.isOn(EventSource.sail),
                onChanged: trip.active
                    ? (_) => boat.toggle(EventSource.sail)
                    : null,
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 12, 8),
              child: Text(
                boat.mode.label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
