import 'dart:math' as math;
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:wheel_choice/wheel_choice.dart';

/// Controller to programmatically manipulate a number wheel (integer, decimal, unit).
class WheelNumberController {
  /// Creates a controller for number wheels.
  WheelNumberController({
    required double value,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.precision = 1,
    this.units,
    String? initialUnit,
    ValueChanged<double>? onChanged,
    ValueChanged<String>? onUnitChanged,
    bool? loop,
  })  : initialValue = value,
        _onChanged = onChanged,
        _onUnitChanged = onUnitChanged,
        _valueNotifier = ValueNotifier<double>(value),
        integer = WheelController<int>(
          value: value.truncate().clamp(min.toInt(), max.toInt()),
          options: [
            for (var i = min.toInt(); i <= max.toInt(); i += (step <= 0 ? 1 : step.toInt())) i
          ],
          loop: loop ?? false,
        ),
        decimal = precision > 0
            ? WheelController<int>(
                value: _extractDecimal(value, precision),
                options: [for (var i = 0; i < math.pow(10, precision); i++) i],
                loop: loop ?? true,
              )
            : null,
        unit = units != null && units.isNotEmpty
            ? WheelController<String>(
                value: initialUnit != null && units.contains(initialUnit)
                    ? initialUnit
                    : units.first,
                options: units,
                loop: false,
              )
            : null {
    _handleValueChanged();
  }

  /// Initial numeric value.
  final double initialValue;

  /// Minimum integer boundary.
  final double min;

  /// Maximum integer boundary.
  final double max;

  /// Step increment for the integer wheel.
  final double step;

  /// Decimal precision (0 for integers only, 1 for .0..9, 2 for .00..99).
  final int precision;

  /// Optional selectable unit list (e.g. `['kg', 'lbs']`).
  final List<String>? units;

  /// Controller for integer wheel.
  final WheelController<int> integer;

  /// Controller for decimal fraction wheel.
  final WheelController<int>? decimal;

  /// Controller for unit wheel.
  final WheelController<String>? unit;

  ValueChanged<double>? _onChanged;
  ValueChanged<String>? _onUnitChanged;
  final ValueNotifier<double> _valueNotifier;

  /// Current double value.
  double get value => _valueNotifier.value;

  /// Read-only listenable for the numeric value.
  ValueListenable<double> get valueListenable => _valueNotifier;

  /// Current selected unit.
  String? get currentUnit => unit?.value;

  static int _extractDecimal(double val, int prec) {
    if (prec <= 0) return 0;
    final frac = (val - val.truncate()).abs();
    final factor = math.pow(10, prec).toInt();
    return (frac * factor).round() % factor;
  }

  /// Updates onChanged callback.
  void setOnChanged(ValueChanged<double>? f) => _onChanged = f;

  /// Updates onUnitChanged callback.
  void setOnUnitChanged(ValueChanged<String>? f) => _onUnitChanged = f;

  /// Jumps wheels to the provided [val].
  void jumpToValue(double val, {bool notify = true}) {
    final intPart = val.truncate().clamp(min.toInt(), max.toInt());
    integer.jumpToValue(intPart, notify: notify);
    if (decimal != null) {
      decimal!.jumpToValue(_extractDecimal(val, precision), notify: notify);
    }
    _valueNotifier.value = val;
    if (notify) {
      _onChanged?.call(val);
    }
  }

  /// Animates wheels to the provided [val].
  Future<void> animateToValue(
    double val, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
    bool notify = true,
  }) async {
    final intPart = val.truncate().clamp(min.toInt(), max.toInt());
    final futures = <Future<void>>[
      integer.animateToValue(intPart, duration: duration, curve: curve, notify: notify),
    ];
    if (decimal != null) {
      futures.add(decimal!.animateToValue(
        _extractDecimal(val, precision),
        duration: duration,
        curve: curve,
        notify: notify,
      ));
    }
    await Future.wait(futures);
    _valueNotifier.value = val;
    if (notify) {
      _onChanged?.call(val);
    }
  }

  /// Moves the integer wheel to the next item.
  Future<bool> nextInteger({bool animate = true, Duration? duration, Curve? curve}) =>
      integer.next(animate: animate, duration: duration, curve: curve);

  /// Moves the integer wheel to the previous item.
  Future<bool> previousInteger({bool animate = true, Duration? duration, Curve? curve}) =>
      integer.previous(animate: animate, duration: duration, curve: curve);

  void _handleValueChanged() {
    void emitChange() {
      final intPart = integer.value ?? min.toInt();
      final decPart = decimal?.value ?? 0;
      final factor = math.pow(10, precision);
      final double resolved = intPart + (decPart / factor);
      _valueNotifier.value = resolved;
      _onChanged?.call(resolved);
    }

    integer.setOnChanged((_) => emitChange());
    decimal?.setOnChanged((_) => emitChange());
    unit?.setOnChanged((u) => _onUnitChanged?.call(u));
  }

  /// Disposes controllers and notifiers.
  void dispose() {
    _valueNotifier.dispose();
    integer.dispose();
    decimal?.dispose();
    unit?.dispose();
  }
}
