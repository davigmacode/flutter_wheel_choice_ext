import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  testWidgets('WheelDateChoiceFormField validates and shows error message', (tester) async {
    final formKey = GlobalKey<FormState>();
    DateTime? saved;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: WheelDateChoiceFormField(
              initialValue: DateTime(2025, 1, 1),
              validator: (val) {
                if (val != null && val.year < 2026) {
                  return 'Year must be 2026 or later';
                }
                return null;
              },
              onSaved: (val) => saved = val,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Year must be 2026 or later'), findsNothing);

    // Validate form - should trigger error
    final isValid = formKey.currentState!.validate();
    await tester.pumpAndSettle();

    expect(isValid, isFalse);
    expect(find.text('Year must be 2026 or later'), findsOneWidget);
    expect(saved, isNull);
  });

  testWidgets('WheelDateChoiceFormField resets to initial value', (tester) async {
    final formKey = GlobalKey<FormState>();
    final initialDate = DateTime(2025, 3, 15);
    final controller = WheelDateController(value: initialDate);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: WheelDateChoiceFormField(
              controller: controller,
              initialValue: initialDate,
            ),
          ),
        ),
      ),
    );

    // Change value via controller
    controller.jumpToDate(DateTime(2025, 7, 20));
    await tester.pumpAndSettle();
    expect(controller.value, equals(DateTime(2025, 7, 20)));

    // Reset form
    formKey.currentState!.reset();
    await tester.pumpAndSettle();

    expect(controller.value, equals(initialDate));
    controller.dispose();
  });
}
