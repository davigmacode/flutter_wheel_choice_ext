import 'package:flutter/widgets.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:intl/intl.dart';

/// Provides label callbacks for rendering day, month, and year values.
class WheelDateLabel {
  /// Creates a set of optional label functions per date part.
  const WheelDateLabel({this.day, this.month, this.year});

  /// Creates labels based on [intl] date patterns and optional [locale].
  factory WheelDateLabel.pattern({
    String? locale,
    String? day,
    String? month,
    String? year,
  }) {
    final dayPattern = day ?? 'd';
    final monthPattern = month ?? 'MMMM';
    final yearPattern = year ?? 'y';

    final dfDay = DateFormat(dayPattern, locale);
    final dfMonth = DateFormat(monthPattern, locale);
    final dfYear = DateFormat(yearPattern, locale);

    return WheelDateLabel(
      day: (int d) => dfDay.format(DateTime(0, 1, d)),
      month: (int m) => dfMonth.format(DateTime(0, m)),
      year: (int y) => dfYear.format(DateTime(y)),
    );
  }

  /// Creates localized labels using the context locale and optional patterns.
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

  /// Label for day values.
  final WheelItemLabel<int>? day;
  /// Label for month values.
  final WheelItemLabel<int>? month;
  /// Label for year values.
  final WheelItemLabel<int>? year;

  /// Two [WheelDateLabel]s are equal when their label callbacks are the same.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelDateLabel &&
        other.day == day &&
        other.month == month &&
        other.year == year;
  }

  /// Combines the hash codes of the three labels.
  @override
  int get hashCode => Object.hash(day, month, year);
}
