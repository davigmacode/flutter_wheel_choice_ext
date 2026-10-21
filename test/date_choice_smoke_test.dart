import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wheel_choice_ext/wheel_choice_ext.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US', null);
  });

  testWidgets('WheelDateChoice renders 3 wheels (DMY)', (tester) async {
    DateTime? changed;
    final controller = WheelDateController(
      value: DateTime(2024, 2, 10),
      onChanged: (d) => changed = d,
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en', 'US')],
        home: Scaffold(
          body: Center(
            child: WheelDateChoice.raw(
              controller: controller,
              itemLabel: WheelDateLabel.pattern(locale: 'en_US'),
              order: WheelDateOrder.dmy,
            ),
          ),
        ),
      ),
    );

    // Should render three WheelChoice<int> columns
    final wheelFinder = find.byWidgetPredicate((w) => w is WheelChoice<int>);
    expect(wheelFinder, findsNWidgets(3));

    // Drag the day wheel upwards by more than one item extent to change value
    await tester.drag(wheelFinder.first, const Offset(0, -60));
    await tester.pumpAndSettle();

    // Callback should have been triggered with a new date
    expect(changed, isNotNull);
    expect(changed!.day, isNot(equals(10)));
  });
}
