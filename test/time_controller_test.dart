import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  group('WheelTimeController', () {
    test('24-hour mode initializes and resolves values', () {
      final initial = const TimeOfDay(hour: 14, minute: 30);
      final controller = WheelTimeController(
        value: initial,
        use24hFormat: true,
      );

      expect(controller.value, equals(initial));
      expect(controller.valueListenable.value, equals(initial));
      expect(controller.hour.value, equals(14));
      expect(controller.minute.value, equals(30));
      expect(controller.period, isNull);
      controller.dispose();
    });

    test('12-hour mode initializes with 1..12 and AM/PM', () {
      final initial = const TimeOfDay(hour: 14, minute: 45); // 2:45 PM
      final controller = WheelTimeController(
        value: initial,
        use24hFormat: false,
      );

      expect(controller.hour.value, equals(2));
      expect(controller.minute.value, equals(45));
      expect(controller.period?.value, equals(WheelTimePeriod.pm));
      expect(controller.value, equals(initial));
      controller.dispose();
    });

    test('12-hour mode midnight and noon hour resolution', () {
      final midnight = const TimeOfDay(hour: 0, minute: 0);
      final cMidnight = WheelTimeController(value: midnight, use24hFormat: false);
      expect(cMidnight.hour.value, equals(12));
      expect(cMidnight.period?.value, equals(WheelTimePeriod.am));
      cMidnight.dispose();

      final noon = const TimeOfDay(hour: 12, minute: 0);
      final cNoon = WheelTimeController(value: noon, use24hFormat: false);
      expect(cNoon.hour.value, equals(12));
      expect(cNoon.period?.value, equals(WheelTimePeriod.pm));
      cNoon.dispose();
    });

    test('jumpToTime updates value in both modes', () {
      final controller = WheelTimeController(
        value: const TimeOfDay(hour: 8, minute: 0),
        use24hFormat: false,
      );

      controller.jumpToTime(const TimeOfDay(hour: 20, minute: 15)); // 8:15 PM
      expect(controller.value, equals(const TimeOfDay(hour: 20, minute: 15)));
      expect(controller.hour.value, equals(8));
      expect(controller.minute.value, equals(15));
      expect(controller.period?.value, equals(WheelTimePeriod.pm));
      controller.dispose();
    });

    test('togglePeriod switches between AM and PM', () async {
      final controller = WheelTimeController(
        value: const TimeOfDay(hour: 9, minute: 30), // 9:30 AM
        use24hFormat: false,
      );

      await controller.togglePeriod(animate: false);
      expect(controller.value, equals(const TimeOfDay(hour: 21, minute: 30))); // 9:30 PM

      await controller.togglePeriod(animate: false);
      expect(controller.value, equals(const TimeOfDay(hour: 9, minute: 30))); // 9:30 AM
      controller.dispose();
    });

    test('stepping helpers move hour and minute', () async {
      final controller = WheelTimeController(
        value: const TimeOfDay(hour: 10, minute: 15),
        use24hFormat: true,
      );

      await controller.nextHour(animate: false);
      expect(controller.value.hour, equals(11));

      await controller.previousHour(animate: false);
      expect(controller.value.hour, equals(10));

      await controller.nextMinute(animate: false);
      expect(controller.value.minute, equals(16));

      await controller.previousMinute(animate: false);
      expect(controller.value.minute, equals(15));
      controller.dispose();
    });

    test('minuteStep rounds to nearest option', () {
      final controller = WheelTimeController(
        value: const TimeOfDay(hour: 10, minute: 14),
        minuteStep: 5,
      );

      // 14 is closest to 15
      expect(controller.minute.value, equals(15));
      controller.dispose();
    });
  });
}
