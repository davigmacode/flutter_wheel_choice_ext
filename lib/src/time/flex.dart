/// Flex factors for hour, minute, and period columns.
class WheelTimeFlex {
  /// Creates flex configuration with defaults 4:4:3.
  const WheelTimeFlex({
    this.hour = 4,
    this.minute = 4,
    this.period = 3,
  });

  /// Flex factor for hour column.
  final int hour;

  /// Flex factor for minute column.
  final int minute;

  /// Flex factor for period column (used only in 12h mode).
  final int period;

  /// Two [WheelTimeFlex]s are equal when all factors match.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelTimeFlex &&
        other.hour == hour &&
        other.minute == minute &&
        other.period == period;
  }

  /// Hash based on the three flex values.
  @override
  int get hashCode => Object.hash(hour, minute, period);
}
