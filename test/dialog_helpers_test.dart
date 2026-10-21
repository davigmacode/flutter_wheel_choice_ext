import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  testWidgets('showWheelDatePicker opens modal and returns selected date on Done', (tester) async {
    DateTime? selected;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selected = await showWheelDatePicker(
                  context: context,
                  initialDate: DateTime(2025, 5, 10),
                );
              },
              child: const Text('Open Date Picker'),
            ),
          ),
        ),
      ),
    );

    // Tap button to open modal
    await tester.tap(find.text('Open Date Picker'));
    await tester.pumpAndSettle();

    // Verify modal is open
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    expect(find.byType(WheelDateChoice), findsOneWidget);

    // Tap Done
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(selected, equals(DateTime(2025, 5, 10)));
  });

  testWidgets('showWheelTimePicker returns null on Cancel', (tester) async {
    TimeOfDay? selected = const TimeOfDay(hour: 12, minute: 0);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: InkRipple.splashFactory),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selected = await showWheelTimePicker(
                  context: context,
                  initialTime: const TimeOfDay(hour: 15, minute: 30),
                );
              },
              child: const Text('Open Time Picker'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Time Picker'));
    await tester.pumpAndSettle();

    expect(find.text('Select Time'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
  });
}
