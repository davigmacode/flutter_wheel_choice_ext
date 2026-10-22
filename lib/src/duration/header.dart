import 'package:wheel_choice/wheel_choice.dart';

/// Header configuration for duration columns (days, hours, minutes, seconds).
class WheelDurationHeader extends WheelHeader {
  /// Creates headers for duration columns.
  const WheelDurationHeader({
    super.key,
    super.align,
    super.decoration,
    super.textStyle,
    super.extent,
    this.days,
    this.hours,
    this.minutes,
    this.seconds,
  });

  /// Header for days column.
  final WheelHeader? days;

  /// Header for hours column.
  final WheelHeader? hours;

  /// Header for minutes column.
  final WheelHeader? minutes;

  /// Header for seconds column.
  final WheelHeader? seconds;

  /// Returns [days] with defaults inherited from this header.
  WheelHeader? get daysX => days != null ? asDefaultFor(days!) : null;

  /// Returns [hours] with defaults inherited from this header.
  WheelHeader? get hoursX => hours != null ? asDefaultFor(hours!) : null;

  /// Returns [minutes] with defaults inherited from this header.
  WheelHeader? get minutesX => minutes != null ? asDefaultFor(minutes!) : null;

  /// Returns [seconds] with defaults inherited from this header.
  WheelHeader? get secondsX => seconds != null ? asDefaultFor(seconds!) : null;
}
