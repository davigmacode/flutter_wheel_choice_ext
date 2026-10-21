import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  group('WheelNumberController & Choice', () {
    test('initializes integer, decimal, and unit values', () {
      final controller = WheelNumberController(
        value: 65.5,
        min: 0,
        max: 200,
        precision: 1,
        units: const ['kg', 'lbs'],
        initialUnit: 'kg',
      );

      expect(controller.value, equals(65.5));
      expect(controller.integer.value, equals(65));
      expect(controller.decimal?.value, equals(5));
      expect(controller.currentUnit, equals('kg'));

      controller.jumpToValue(70.2);
      expect(controller.value, closeTo(70.2, 0.001));

      controller.dispose();
    });

    testWidgets('WheelNumberChoice renders integer, separator, decimal, and unit', (tester) async {
      final controller = WheelNumberController(
        value: 175.8,
        min: 100,
        max: 220,
        precision: 1,
        units: const ['cm', 'inch'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WheelNumberChoice.raw(controller: controller),
            ),
          ),
        ),
      );

      // Integer wheel + decimal wheel + unit wheel
      expect(find.byType(WheelChoice<int>), findsNWidgets(2));
      expect(find.byType(WheelChoice<String>), findsOneWidget);
      expect(find.text('.'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('WheelNumberChoiceFormField validates weight range', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: WheelNumberChoiceFormField(
                initialValue: 35.0,
                min: 20,
                max: 150,
                validator: (numVal) {
                  if (numVal != null && numVal < 40.0) {
                    return 'Weight must be at least 40 kg';
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
      expect(find.text('Weight must be at least 40 kg'), findsOneWidget);
    });
  });
}
