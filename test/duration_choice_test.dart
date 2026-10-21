import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  group('WheelDurationController & Choice', () {
    test('initializes duration and exposes reactive value', () {
      final initial = const Duration(hours: 2, minutes: 45, seconds: 30);
      final controller = WheelDurationController(value: initial);

      expect(controller.value, equals(initial));
      expect(controller.hours.value, equals(2));
      expect(controller.minutes.value, equals(45));
      expect(controller.seconds.value, equals(30));

      controller.jumpToDuration(const Duration(hours: 1, minutes: 15, seconds: 0));
      expect(controller.value, equals(const Duration(hours: 1, minutes: 15, seconds: 0)));

      controller.dispose();
    });

    test('stepping helpers move hours, minutes, and seconds', () async {
      final controller = WheelDurationController(
        value: const Duration(hours: 1, minutes: 10, seconds: 20),
      );

      await controller.nextHour(animate: false);
      expect(controller.value.inHours, equals(2));

      await controller.previousMinute(animate: false);
      expect(controller.value.inMinutes % 60, equals(9));

      await controller.nextSecond(animate: false);
      expect(controller.value.inSeconds % 60, equals(21));

      controller.dispose();
    });

    testWidgets('WheelDurationChoice renders 3 columns and inherits theme', (tester) async {
      final controller = WheelDurationController(
        value: const Duration(hours: 1, minutes: 20, seconds: 30),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WheelChoiceTheme(
              data: const WheelChoiceThemeData(itemExtent: 52),
              child: WheelDurationChoice.raw(controller: controller),
            ),
          ),
        ),
      );

      expect(find.byType(WheelChoice<int>), findsNWidgets(3));
      final firstPicker = tester.widget<WheelChoice<int>>(find.byType(WheelChoice<int>).first);
      expect(firstPicker.itemExtent, equals(52));

      controller.dispose();
    });

    testWidgets('WheelDurationChoiceFormField validates minimum duration', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: WheelDurationChoiceFormField(
                initialValue: const Duration(minutes: 5),
                validator: (d) {
                  if (d != null && d.inMinutes < 15) {
                    return 'Timer must be at least 15 minutes';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Timer must be at least 15 minutes'), findsOneWidget);
    });
  });
}
