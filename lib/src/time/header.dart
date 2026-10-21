import 'package:wheel_choice/wheel_choice.dart';

/// Header configuration for the hour, minute, and period columns.
class WheelTimeHeader extends WheelHeader {
  /// Creates a header set for the time columns.
  const WheelTimeHeader({
    super.key,
    super.align,
    super.decoration,
    super.textStyle,
    super.extent,
    this.hour,
    this.minute,
    this.period,
  });

  /// Header used above the hour column.
  final WheelHeader? hour;

  /// Header used above the minute column.
  final WheelHeader? minute;

  /// Header used above the period column.
  final WheelHeader? period;

  /// Returns [hour] with defaults inherited from this header.
  WheelHeader? get hourX => hour != null ? asDefaultFor(hour!) : null;

  /// Returns [minute] with defaults inherited from this header.
  WheelHeader? get minuteX => minute != null ? asDefaultFor(minute!) : null;

  /// Returns [period] with defaults inherited from this header.
  WheelHeader? get periodX => period != null ? asDefaultFor(period!) : null;
}
