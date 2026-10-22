import 'package:wheel_choice/wheel_choice.dart';

/// Label formatters for duration columns (days, hours, minutes, seconds).
class WheelDurationLabel {
  /// Creates a set of optional label functions per duration part.
  const WheelDurationLabel({
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
  });

  /// Factory with suffix strings (e.g. "2 d", "1 h", "30 m", "45 s").
  factory WheelDurationLabel.suffix({
    String daySuffix = ' d',
    String hourSuffix = ' h',
    String minuteSuffix = ' m',
    String secondSuffix = ' s',
  }) {
    return WheelDurationLabel(
      days: (d) => '$d$daySuffix',
      hours: (h) => '$h$hourSuffix',
      minutes: (m) => '$m$minuteSuffix',
      seconds: (s) => '$s$secondSuffix',
    );
  }

  /// Factory with two-digit padded format (e.g. "02", "01", "30", "45").
  factory WheelDurationLabel.padded() {
    return WheelDurationLabel(
      days: (d) => d.toString().padLeft(2, '0'),
      hours: (h) => h.toString().padLeft(2, '0'),
      minutes: (m) => m.toString().padLeft(2, '0'),
      seconds: (s) => s.toString().padLeft(2, '0'),
    );
  }

  /// Label for days.
  final WheelItemLabel<int>? days;

  /// Label for hours.
  final WheelItemLabel<int>? hours;

  /// Label for minutes.
  final WheelItemLabel<int>? minutes;

  /// Label for seconds.
  final WheelItemLabel<int>? seconds;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelDurationLabel &&
        other.days == days &&
        other.hours == hours &&
        other.minutes == minutes &&
        other.seconds == seconds;
  }

  @override
  int get hashCode => Object.hash(days, hours, minutes, seconds);
}
