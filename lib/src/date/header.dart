import 'package:wheel_choice/wheel_choice.dart';

/// Header configuration for the day, month, and year columns.
class WheelDateHeader extends WheelHeader {
  /// Creates a header set for the three columns.
  const WheelDateHeader({
    super.key,
    super.align,
    super.decoration,
    super.textStyle,
    super.extent,
    required this.day,
    required this.month,
    required this.year,
  });

  /// Header used above the day column.
  final WheelHeader day;
  /// Header used above the month column.
  final WheelHeader month;
  /// Header used above the year column.
  final WheelHeader year;

  /// Returns [day] with defaults inherited from this header.
  WheelHeader get dayX => asDefaultFor(day);
  /// Returns [month] with defaults inherited from this header.
  WheelHeader get monthX => asDefaultFor(month);
  /// Returns [year] with defaults inherited from this header.
  WheelHeader get yearX => asDefaultFor(year);
}
