import 'package:flutter/material.dart';

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
              for (final source in EventSource.values) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(source.label),
                    Switch(
                      value: boat.isOn(source),
                      onChanged: (_) => boat.toggle(source),
                    ),
                  ],
                ),
              ],
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
              for (final mode in Mode.values) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${mode.label} time:'),
                    Text(
                      boat.time[mode].toString().split('.')[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
