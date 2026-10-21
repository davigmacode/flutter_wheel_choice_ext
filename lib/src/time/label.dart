import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'types.dart';

/// Provides label callbacks for rendering hour, minute, and period values.
class WheelTimeLabel {
  /// Creates a set of optional label functions per time part.
  const WheelTimeLabel({this.hour, this.minute, this.period});

  /// Factory using format patterns for hour and minute, with locale support.
  factory WheelTimeLabel.pattern({
    String? locale,
    String? hourPattern,
    String? minutePattern,
  }) {
    final hPattern = hourPattern ?? 'HH';
    final mPattern = minutePattern ?? 'mm';
    final dfHour = DateFormat(hPattern, locale);
    final dfMinute = DateFormat(mPattern, locale);

    return WheelTimeLabel(
      hour: (int h) => dfHour.format(DateTime(2025, 1, 1, h)),
      minute: (int m) => dfMinute.format(DateTime(2025, 1, 1, 0, m)),
      period: (WheelTimePeriod p) => p.label,
    );
  }

  /// Creates localized labels using the context locale.
  factory WheelTimeLabel.of(
    BuildContext context, {
    String? hourPattern,
    String? minutePattern,
  }) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    return WheelTimeLabel.pattern(
      locale: locale,
      hourPattern: hourPattern,
      minutePattern: minutePattern,
    );
  }

  /// Label for hour values.
  final WheelItemLabel<int>? hour;

  /// Label for minute values.
  final WheelItemLabel<int>? minute;

  /// Label for period values.
  final WheelItemLabel<WheelTimePeriod>? period;

  /// Two [WheelTimeLabel]s are equal when their label callbacks are the same.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelTimeLabel &&
        other.hour == hour &&
        other.minute == minute &&
        other.period == period;
  }

  /// Combines the hash codes of the three labels.
  @override
  int get hashCode => Object.hash(hour, minute, period);
}
