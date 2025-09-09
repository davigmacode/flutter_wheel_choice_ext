import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('id', null);
  });
  test('WheelDateLabel.pattern formats month names (en_US)', () {
    final label = WheelDateLabel.pattern(locale: 'en_US');
    expect(label.month?.call(1), 'January');
    expect(label.month?.call(2), 'February');
    expect(label.day?.call(5), '5');
    expect(label.year?.call(2024), '2024');
  });

  test('WheelDateLabel.pattern formats month names (id)', () {
    final label = WheelDateLabel.pattern(locale: 'id');
    // Indonesian locale full month name for 3 is "Maret"
    expect(label.month?.call(3), 'Maret');
  });
}
