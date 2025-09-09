import 'package:wheel_choice/wheel_choice.dart';

/// Builds custom item widgets for each date wheel (day, month, year).
class WheelDateBuilder {
  /// Creates a builder with optional per-part builders.
  const WheelDateBuilder({this.day, this.month, this.year});

  /// Creates a builder that uses the same [builder] for day, month, and year.
  const WheelDateBuilder.all(WheelItemBuilder<int>? builder)
    : day = builder,
      month = builder,
      year = builder;

  /// Builder for each day option.
  final WheelItemBuilder<int>? day;

  /// Builder for each month option.
  final WheelItemBuilder<int>? month;

  /// Builder for each year option.
  final WheelItemBuilder<int>? year;

  /// Two [WheelDateBuilder]s are equal when their builders are equal by
  /// reference for day, month, and year.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelDateBuilder &&
        other.day == day &&
        other.month == month &&
        other.year == year;
  }

  /// Combines the hash codes of the three builders.
  @override
  int get hashCode => Object.hash(day, month, year);
}
