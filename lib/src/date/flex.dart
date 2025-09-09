/// Flex factors for day, month, and year columns.
class WheelDateFlex {
  /// Creates flex configuration with defaults 3:4:4 for D:M:Y.
  const WheelDateFlex({
    this.day = 3,
    this.month = 4,
    this.year = 4,
  });

  /// Flex factor for day column.
  final int day;

  /// Flex factor for month column.
  final int month;

  /// Flex factor for year column.
  final int year;

  /// Two [WheelDateFlex]s are equal when all factors match.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelDateFlex &&
        other.day == day &&
        other.month == month &&
        other.year == year;
  }

  /// Hash based on the three flex values.
  @override
  int get hashCode => Object.hash(day, month, year);
}
