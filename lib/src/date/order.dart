import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef WheelDateOrderCallback = List<Widget> Function(List<Widget> pickers);

class WheelDateOrder {
  const WheelDateOrder(this.callback);

  final WheelDateOrderCallback callback;

  /// Determines the order of date components (day, month, year)
  /// based on the current locale using [DateFormat.yMd].
  factory WheelDateOrder.of(BuildContext context) {
    // Get the locale string (e.g., "en-US", "id-ID")
    final locale = Localizations.localeOf(context).toLanguageTag();

    // Get the date format pattern (e.g., "M/d/y" -> "mdy")
    final pattern = DateFormat.yMd(locale).pattern?.toLowerCase() ?? 'mdy';

    // Helper to map missing component index (-1) to a large value
    int pos(String ch) {
      final i = pattern.indexOf(ch);
      return i < 0 ? 999 : i;
    }

    // Define the keys in standard order
    final keys = ['d', 'm', 'y'];

    // Sort the keys based on their index in the pattern
    // So the component with the lowest index comes first
    final sorted = [...keys]
      ..sort((a, b) => pos(a).compareTo(pos(b)));

    return WheelDateOrder((pickers) {
      // Expecting exactly 3 pickers: [dayPicker, monthPicker, yearPicker]
      if (pickers.length != 3) return pickers;

      // Map keys to their corresponding picker
      final map = {
        'd': pickers[0],
        'm': pickers[1],
        'y': pickers[2],
      };

      // Return the pickers in the sorted (localized) order
      return sorted.map((key) => map[key]!).toList();
    });
  }

  static const dmy = WheelDateOrder(_dmy);
  static List<Widget> _dmy(List<Widget> pickers) => pickers;

  static const mdy = WheelDateOrder(_mdy);
  static List<Widget> _mdy(List<Widget> pickers) {
    final [day, month, year] = pickers;
    return [month, day, year];
  }

  static const ymd = WheelDateOrder(_ymd);
  static List<Widget> _ymd(List<Widget> pickers) {
    final [day, month, year] = pickers;
    return [year, month, day];
  }

  static const ydm = WheelDateOrder(_ydm);
  static List<Widget> _ydm(List<Widget> pickers) {
    final [day, month, year] = pickers;
    return [year, day, month];
  }
}
