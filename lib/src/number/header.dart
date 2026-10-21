import 'package:wheel_choice/wheel_choice.dart';

/// Header configuration for number columns (integer, decimal, unit).
class WheelNumberHeader extends WheelHeader {
  /// Creates headers for number columns.
  const WheelNumberHeader({
    super.key,
    super.align,
    super.decoration,
    super.textStyle,
    super.extent,
    this.integer,
    this.decimal,
    this.unit,
  });

  /// Header for integer column.
  final WheelHeader? integer;

  /// Header for decimal column.
  final WheelHeader? decimal;

  /// Header for unit column.
  final WheelHeader? unit;

  /// Returns [integer] with defaults inherited from this header.
  WheelHeader? get integerX => integer != null ? asDefaultFor(integer!) : null;

  /// Returns [decimal] with defaults inherited from this header.
  WheelHeader? get decimalX => decimal != null ? asDefaultFor(decimal!) : null;

  /// Returns [unit] with defaults inherited from this header.
  WheelHeader? get unitX => unit != null ? asDefaultFor(unit!) : null;
}
