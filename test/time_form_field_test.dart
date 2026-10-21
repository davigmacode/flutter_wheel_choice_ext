import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  testWidgets('WheelTimeChoiceFormField validates and resets correctly', (tester) async {
    final formKey = GlobalKey<FormState>();
    final initial = const TimeOfDay(hour: 9, minute: 0);
    final controller = WheelTimeController(value: initial, use24hFormat: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: WheelTimeChoiceFormField(
              controller: controller,
              initialValue: initial,
              validator: (t) {
                if (t != null && t.hour < 12) {
                  return 'Afternoon hours only';
                }
                return null;
              },
            ),
          ),
        ),
      ),
    );

    // Initial check (9:00 is before 12)
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pumpAndSettle();
    expect(find.text('Afternoon hours only'), findsOneWidget);

    // Change to valid afternoon hour (14:00)
    controller.jumpToTime(const TimeOfDay(hour: 14, minute: 0));
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
    await tester.pumpAndSettle();
    expect(find.text('Afternoon hours only'), findsNothing);

    // Reset should revert to initial (9:00)
    formKey.currentState!.reset();
    await tester.pumpAndSettle();
    expect(controller.value, equals(initial));

    controller.dispose();
  });
}
