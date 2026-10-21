import 'package:wheel_choice/wheel_choice.dart';
import 'types.dart';

/// Builds custom item widgets for each time wheel (hour, minute, period).
class WheelTimeBuilder {
  /// Creates a builder with optional per-part builders.
  const WheelTimeBuilder({this.hour, this.minute, this.period});

  /// Builder for each hour option.
  final WheelItemBuilder<int>? hour;

  /// Builder for each minute option.
  final WheelItemBuilder<int>? minute;

  /// Builder for each period option.
  final WheelItemBuilder<WheelTimePeriod>? period;

  /// Two [WheelTimeBuilder]s are equal when their builders are equal by
  /// reference for hour, minute, and period.
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelTimeBuilder &&
        other.hour == hour &&
        other.minute == minute &&
        other.period == period;
  }

  /// Combines the hash codes of the three builders.
  @override
  int get hashCode => Object.hash(hour, minute, period);
}
