/// Represents the AM/PM period of a 12-hour clock.
enum WheelTimePeriod {
  am,
  pm;

  /// Whether this period is AM.
  bool get isAm => this == WheelTimePeriod.am;

  /// Whether this period is PM.
  bool get isPm => this == WheelTimePeriod.pm;

  /// String display for the period ('AM' or 'PM').
  String get label => this == WheelTimePeriod.am ? 'AM' : 'PM';
}
