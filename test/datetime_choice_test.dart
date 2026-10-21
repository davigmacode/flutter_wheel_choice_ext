import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  group('WheelDateTimeController & Choice', () {
    test('initializes date and time and emits synchronized DateTime', () {
      final initial = DateTime(2025, 8, 15, 14, 30);
      DateTime? changed;

      final controller = WheelDateTimeController(
        value: initial,
        onChanged: (dt) => changed = dt,
      );

      expect(controller.value, equals(initial));
      expect(controller.date.value, equals(DateTime(2025, 8, 15)));
      expect(controller.time.value, equals(const TimeOfDay(hour: 14, minute: 30)));

      controller.date.jumpToDate(DateTime(2025, 8, 20));
      expect(controller.value, equals(DateTime(2025, 8, 20, 14, 30)));
      expect(changed, equals(DateTime(2025, 8, 20, 14, 30)));

      controller.dispose();
    });

    testWidgets('WheelDateTimeChoice renders both date and time pickers', (tester) async {
      final controller = WheelDateTimeController(
        value: DateTime(2025, 5, 1, 10, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WheelDateTimeChoice.raw(controller: controller),
            ),
          ),
        ),
      );

      // Should find date choice and time choice widgets
      expect(find.byType(WheelDateChoice), findsOneWidget);
      expect(find.byType(WheelTimeChoice), findsOneWidget);

      controller.dispose();
    });

    testWidgets('WheelDateTimeChoiceFormField validates correctly', (tester) async {
      final formKey = GlobalKey<FormState>();
      final dt = DateTime(2025, 6, 1, 8, 0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: WheelDateTimeChoiceFormField(
                initialValue: dt,
                validator: (val) {
                  if (val != null && val.hour < 9) {
                    return 'Must be during office hours (9 AM+)';
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
      expect(find.text('Must be during office hours (9 AM+)'), findsOneWidget);
    });
  });
}
