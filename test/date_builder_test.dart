import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wheel_choice/wheel_choice.dart';

import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  test('WheelDateBuilder equality with null builders', () {
    const a = WheelDateBuilder();
    const b = WheelDateBuilder();
    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
  });

  test('WheelDateBuilder inequality when a builder differs', () {
    // Provide a dummy builder matching WheelItemBuilder<int>
    Widget builder(BuildContext context, WheelItem<int> item) =>
        const SizedBox.shrink();

    final a = WheelDateBuilder(year: builder);
    const b = WheelDateBuilder();
    expect(a == b, isFalse);
  });
}
