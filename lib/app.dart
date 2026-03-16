import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:jacht_log/home_screen.dart';
import 'package:jacht_log/l10n/app_localizations.dart';

class JachtLogApp extends StatelessWidget {
  const JachtLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jacht Log',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.teal)),
      home: const HomeScreen(title: 'Jacht Log'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('pl')],
    );
  }
}
