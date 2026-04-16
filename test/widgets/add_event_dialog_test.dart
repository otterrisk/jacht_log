import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jacht_log/domain/event.dart';
import 'package:jacht_log/l10n/app_localizations.dart';
import 'package:jacht_log/presentation/dto/event_result.dart';
import 'package:jacht_log/presentation/widgets/date_time/date_time_picker.dart';
import 'package:jacht_log/widgets/add_event_dialog.dart';

Future<EventResult?> pumpAddEventDialog(
  WidgetTester tester, {
  required DateTime minTime,
  required DateTime maxTime,
}) async {
  EventResult? result;

  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  result = await showDialog<EventResult>(
                    context: context,
                    builder: (_) =>
                        AddEventDialog(minTime: minTime, maxTime: maxTime),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          );
        },
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();

  return result;
}

void main() {
  testWidgets('renders dialog elements', (tester) async {
    await pumpAddEventDialog(
      tester,
      minTime: DateTime(2020),
      maxTime: DateTime(2030),
    );

    expect(find.text('Add event'), findsOneWidget);
    expect(find.byKey(const Key('eventDropdown')), findsOneWidget);
    expect(find.byKey(const Key('datePicker')), findsOneWidget);
    expect(find.byKey(const Key('timePicker')), findsOneWidget);
    expect(find.byKey(const Key('cancelButton')), findsOneWidget);
    expect(find.byKey(const Key('addButton')), findsOneWidget);
  });

  testWidgets('selecting preset updates UI', (tester) async {
    await pumpAddEventDialog(
      tester,
      minTime: DateTime(2020),
      maxTime: DateTime(2030),
    );

    final dropdown = find.byKey(const Key('eventDropdown'));
    await tester.pumpAndSettle();

    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    final item = find.byKey(
      Key("${EventSource.sail.name}-${EventType.start.name}"),
    );
    await tester.tap(item);
    await tester.pumpAndSettle();

    expect(item, findsOneWidget);
  });

  testWidgets('submit returns EventResult', (tester) async {
    EventResult? result;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,

        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<EventResult>(
                      context: context,
                      builder: (_) => AddEventDialog(
                        minTime: DateTime(2020),
                        maxTime: DateTime(2030),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('eventDropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key("sail-start")));
    await tester.pumpAndSettle();

    final picker = tester.widget<DateTimePicker>(find.byType(DateTimePicker));
    picker.onChanged(DateTime(2025, 7, 12, 17, 15));
    await tester.pump();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result, isA<EventResult>());
    expect(result!.source, EventSource.sail);
    expect(result!.type, EventType.start);
    expect(result!.timestamp, DateTime(2025, 7, 12, 17, 15));
  });

  testWidgets('submit does nothing without preset', (tester) async {
    EventResult? result;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,

        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<EventResult>(
                      context: context,
                      builder: (_) => AddEventDialog(
                        minTime: DateTime(2020),
                        maxTime: DateTime(2030),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(find.text('Add event'), findsOneWidget);
    expect(result, isNull);
  });

  testWidgets('cancel closes dialog without result', (tester) async {
    EventResult? result;

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,

        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await showDialog<EventResult>(
                      context: context,
                      builder: (_) => AddEventDialog(
                        minTime: DateTime(2020),
                        maxTime: DateTime(2030),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Add event'), findsNothing);
    expect(result, isNull);
  });
}
