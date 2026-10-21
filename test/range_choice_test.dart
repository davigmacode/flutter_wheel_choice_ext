import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  group('WheelDateRangeController & Choice', () {
    test('synchronizes start and end date boundaries', () {
      final range = DateTimeRange(
        start: DateTime(2025, 5, 10),
        end: DateTime(2025, 5, 15),
      );

      final controller = WheelDateRangeController(value: range);
      expect(controller.value.start, equals(DateTime(2025, 5, 10)));
      expect(controller.value.end, equals(DateTime(2025, 5, 15)));

      // Moving start past end automatically clamps end forward
      controller.start.jumpToDate(DateTime(2025, 5, 20));
      expect(controller.value.start, equals(DateTime(2025, 5, 20)));
      expect(controller.value.end.isBefore(controller.value.start), isFalse);

      controller.dispose();
    });

    testWidgets('WheelDateRangeChoice renders start and end date wheels', (tester) async {
      final controller = WheelDateRangeController(
        value: DateTimeRange(
          start: DateTime(2025, 6, 1),
          end: DateTime(2025, 6, 10),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: WheelDateRangeChoice.raw(controller: controller),
            ),
          ),
        ),
      );

      // Two WheelDateChoices (start and end)
      expect(find.byType(WheelDateChoice), findsNWidgets(2));
      controller.dispose();
    });

    testWidgets('WheelDateRangeChoiceFormField validates trip duration', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: WheelDateRangeChoiceFormField(
                initialValue: DateTimeRange(
                  start: DateTime(2025, 7, 1),
                  end: DateTime(2025, 7, 2),
                ),
                validator: (r) {
                  if (r != null && r.duration.inDays < 3) {
                    return 'Trip must be at least 3 days';
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
      expect(find.text('Trip must be at least 3 days'), findsOneWidget);
    });
  });
}
