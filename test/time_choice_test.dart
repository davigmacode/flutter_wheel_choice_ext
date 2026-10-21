import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  testWidgets('WheelTimeChoice renders 2 wheels in 24h mode', (tester) async {
    final controller = WheelTimeController(
      value: const TimeOfDay(hour: 15, minute: 30),
      use24hFormat: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WheelTimeChoice.raw(controller: controller),
          ),
        ),
      ),
    );

    // In 24h mode: 2 wheels (hour and minute)
    expect(find.byType(WheelChoice<int>), findsNWidgets(2));
    expect(find.byType(WheelChoice<WheelTimePeriod>), findsNothing);

    controller.dispose();
  });

  testWidgets('WheelTimeChoice renders 3 wheels in 12h mode', (tester) async {
    final controller = WheelTimeController(
      value: const TimeOfDay(hour: 15, minute: 30),
      use24hFormat: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: WheelTimeChoice.raw(controller: controller),
          ),
        ),
      ),
    );

    // In 12h mode: hour, minute, and period
    expect(find.byType(WheelChoice<int>), findsNWidgets(2));
    expect(find.byType(WheelChoice<WheelTimePeriod>), findsOneWidget);

    controller.dispose();
  });

  testWidgets('WheelTimeChoice inherits WheelChoiceTheme', (tester) async {
    const customExtent = 55.0;
    final controller = WheelTimeController(
      value: const TimeOfDay(hour: 10, minute: 0),
      use24hFormat: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WheelChoiceTheme(
            data: const WheelChoiceThemeData(
              itemExtent: customExtent,
            ),
            child: WheelTimeChoice.raw(controller: controller),
          ),
        ),
      ),
    );

    final hourPicker = tester.widget<WheelChoice<int>>(find.byType(WheelChoice<int>).first);
    expect(hourPicker.itemExtent, equals(customExtent));

    final periodPicker = tester.widget<WheelChoice<WheelTimePeriod>>(
      find.byType(WheelChoice<WheelTimePeriod>),
    );
    expect(periodPicker.itemExtent, equals(customExtent));

    controller.dispose();
  });
}
