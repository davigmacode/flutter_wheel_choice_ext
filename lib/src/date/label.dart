import 'package:flutter/widgets.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:intl/intl.dart';

class WheelDateLabel {
  WheelDateLabel({this.day, this.month, this.year});

  factory WheelDateLabel.pattern({
    String? locale,
    String? day,
    String? month,
    String? year,
  }) {
    day ??= 'd';
    month ??= 'MMMM';
    year ??= 'y';
    return WheelDateLabel(
      day: (int d) => DateFormat(day, locale).format(DateTime(0, 1, d)),
      month: (int m) => DateFormat(month, locale).format(DateTime(0, m)),
      year: (int y) => DateFormat(year, locale).format(DateTime(y)),
    );
  }

  factory WheelDateLabel.of(
    BuildContext context, {
    String? day,
    String? month,
    String? year,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return WheelDateLabel.pattern(
      locale: locale,
      day: day,
      month: month,
      year: year,
    );
  }

  final WheelItemLabel<int>? day;
  final WheelItemLabel<int>? month;
  final WheelItemLabel<int>? year;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelDateLabel &&
        other.day == day &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(day, month, year);
}
