import 'package:flutter/material.dart';
import 'package:jacht_log/home_screen.dart';

class JachtLogApp extends StatelessWidget {
  const JachtLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jacht Log',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const HomeScreen(title: 'Jacht Log'),
    );
  }
}
