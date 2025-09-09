import 'package:flutter_test/flutter_test.dart';

import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  test('WheelDateFlex equality and hashCode', () {
    const a = WheelDateFlex(day: 3, month: 4, year: 4);
    const b = WheelDateFlex(day: 3, month: 4, year: 4);
    const c = WheelDateFlex(day: 2, month: 4, year: 4);

    expect(a, equals(b));
    expect(a.hashCode, equals(b.hashCode));
    expect(a == c, isFalse);
  });
}
