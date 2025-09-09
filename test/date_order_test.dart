import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:wheel_choice_ext/wheel_choice_ext.dart';

Widget _buildOrderedRow(BuildContext context) {
  final order = WheelDateOrder.of(context);
  final day = const SizedBox(key: ValueKey('D'));
  final month = const SizedBox(key: ValueKey('M'));
  final year = const SizedBox(key: ValueKey('Y'));
  final children = order.callback([day, month, year]);
  return Row(children: children);
}

List<String> _keysFromRow(WidgetTester tester) {
  final row = tester.widget<Row>(find.byType(Row));
  return row.children
      .map((w) => (w.key as ValueKey<String>).value)
      .toList(growable: false);
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_US', null);
    await initializeDateFormatting('id', null);
    await initializeDateFormatting('ja', null);
  });
  test('static orders map correctly', () {
    final day = const SizedBox(key: ValueKey('D'));
    final month = const SizedBox(key: ValueKey('M'));
    final year = const SizedBox(key: ValueKey('Y'));

    expect(
      WheelDateOrder.dmy
          .callback([day, month, year])
          .map((w) => (w.key as ValueKey).value),
      ['D', 'M', 'Y'],
    );
    expect(
      WheelDateOrder.mdy
          .callback([day, month, year])
          .map((w) => (w.key as ValueKey).value),
      ['M', 'D', 'Y'],
    );
    expect(
      WheelDateOrder.ymd
          .callback([day, month, year])
          .map((w) => (w.key as ValueKey).value),
      ['Y', 'M', 'D'],
    );
    expect(
      WheelDateOrder.ydm
          .callback([day, month, year])
          .map((w) => (w.key as ValueKey).value),
      ['Y', 'D', 'M'],
    );
  });
  testWidgets('WheelDateOrder.of uses MDY for en_US', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en', 'US'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('id', 'ID'),
          Locale('ja', 'JP'),
        ],
        home: Builder(builder: _buildOrderedRow),
      ),
    );
    final keys = _keysFromRow(tester);
    expect(keys, ['M', 'D', 'Y']);
  });

  testWidgets('WheelDateOrder.of uses DMY for id', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('id'),
          Locale('ja'),
        ],
        home: Builder(builder: _buildOrderedRow),
      ),
    );
    final keys = _keysFromRow(tester);
    expect(keys, ['D', 'M', 'Y']);
  });

  testWidgets('WheelDateOrder.of uses YMD for ja', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ja'),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('id'),
          Locale('ja'),
        ],
        home: Builder(builder: _buildOrderedRow),
      ),
    );
    final keys = _keysFromRow(tester);
    expect(keys, ['Y', 'M', 'D']);
  });
}
