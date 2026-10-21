import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  testWidgets('WheelDateChoice inherits properties from WheelChoiceTheme', (tester) async {
    const themeItemExtent = 60.0;
    final controller = WheelDateController(value: DateTime(2025, 5, 10));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WheelChoiceTheme(
            data: const WheelChoiceThemeData(
              itemExtent: themeItemExtent,
              itemVisible: 5,
            ),
            child: WheelDateChoice.raw(controller: controller),
          ),
        ),
      ),
    );

    final choiceFinders = find.byType(WheelChoice<int>);
    expect(choiceFinders, findsNWidgets(3));

    // Verify all child WheelChoices inherited itemExtent
    for (final element in choiceFinders.evaluate()) {
      final widget = element.widget as WheelChoice<int>;
      expect(widget.itemExtent, equals(themeItemExtent));
      expect(widget.itemVisible, equals(5));
    }

    controller.dispose();
  });
}
