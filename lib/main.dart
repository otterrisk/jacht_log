import 'package:flutter/material.dart';
import 'package:hello/event.dart';

import 'domain.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
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
  final boat = Boat();

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    return ListenableBuilder(
      listenable: boat,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
          ),
          body: Column(
            children: [
              Card(
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 3,
                    children: [
                      SwitchListTile(
                        title: Text(EventSource.port.label),
                        value: boat.isOn(EventSource.port),
                        onChanged: (_) => boat.toggle(EventSource.port),
                      ),
                      SwitchListTile(
                        title: Text(EventSource.engine.label),
                        value: boat.isOn(EventSource.engine),
                        onChanged: (_) => boat.toggle(EventSource.engine),
                      ),
                      SwitchListTile(
                        title: Text(EventSource.anchor.label),
                        value: boat.isOn(EventSource.anchor),
                        onChanged: (_) => boat.toggle(EventSource.anchor),
                      ),
                      SwitchListTile(
                        title: Text(EventSource.sail.label),
                        value: boat.isOn(EventSource.sail),
                        onChanged: (_) => boat.toggle(EventSource.sail),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Current mode:'),
                  Text(
                    boat.mode.label,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
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
                        _timeRow('${mode.label} time', boat.time[mode.index]),
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
}
