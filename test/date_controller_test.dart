import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  group('WheelDateController', () {
    test('value getter and valueListenable return initial date', () {
      final initial = DateTime(2025, 6, 15);
      final controller = WheelDateController(value: initial);

      expect(controller.value, equals(initial));
      expect(controller.valueListenable.value, equals(initial));
      controller.dispose();
    });

    test('jumpToDate updates value and notifies listeners', () {
      final initial = DateTime(2025, 1, 10);
      final target = DateTime(2025, 5, 20);
      DateTime? changed;

      final controller = WheelDateController(
        value: initial,
        onChanged: (d) => changed = d,
      );

      controller.jumpToDate(target);

      expect(controller.value, equals(target));
      expect(controller.valueListenable.value, equals(target));
      expect(changed, equals(target));
      controller.dispose();
    });

    test('month change clamps day when month has fewer days', () async {
      // Start at 31 January 2025
      final initial = DateTime(2025, 1, 31);
      final controller = WheelDateController(value: initial);

      // Jump month to February (non-leap year, 28 days)
      controller.month.jumpToValue(2);
      await Future<void>.delayed(Duration.zero);

      expect(controller.value.month, equals(2));
      expect(controller.value.day, equals(28));
      controller.dispose();
    });

    test('stepping helpers move day, month, and year correctly', () async {
      final initial = DateTime(2025, 3, 10);
      final controller = WheelDateController(value: initial);

      await controller.nextDay(animate: false);
      expect(controller.value.day, equals(11));

      await controller.previousDay(animate: false);
      expect(controller.value.day, equals(10));

      await controller.nextMonth(animate: false);
      expect(controller.value.month, equals(4));

      await controller.previousMonth(animate: false);
      expect(controller.value.month, equals(3));

      await controller.nextYear(animate: false);
      expect(controller.value.year, equals(2026));

      await controller.previousYear(animate: false);
      expect(controller.value.year, equals(2025));

      controller.dispose();
    });
  });
}
