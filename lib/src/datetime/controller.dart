import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wheel_choice_ext/src/common/types.dart';
import 'package:wheel_choice_ext/src/date/controller.dart';
import 'package:wheel_choice_ext/src/time/controller.dart';

/// Controller to programmatically manipulate a composite date and time wheel.
///
/// Composes underlying [WheelDateController] and [WheelTimeController] instances
/// into a unified [DateTime] model.
class WheelDateTimeController {
  /// Creates a unified controller for date and time.
  WheelDateTimeController({
    required DateTime value,
    this.use24hFormat = true,
    this.minuteStep = 1,
    ValueChanged<DateTime>? onChanged,
    ValueTransformer<DateTime, bool>? disableDate,
    DateTime? minDate,
    DateTime? maxDate,
    int? minYear,
    int? maxYear,
    int? radiusYear,
    int? anchorYear,
    bool? loop,
  })  : initialValue = value,
        _onChanged = onChanged,
        _valueNotifier = ValueNotifier<DateTime>(value),
        date = WheelDateController(
          value: DateTime(value.year, value.month, value.day),
          disableDate: disableDate,
          minDate: minDate,
          maxDate: maxDate,
          minYear: minYear,
          maxYear: maxYear,
          radiusYear: radiusYear,
          anchorYear: anchorYear,
          loop: loop,
        ),
        time = WheelTimeController(
          value: TimeOfDay.fromDateTime(value),
          use24hFormat: use24hFormat,
          minuteStep: minuteStep,
          loop: loop,
        ) {
    _initSync();
  }

  /// Initial DateTime value configured at creation.
  final DateTime initialValue;

  /// Whether time operates in 24-hour mode.
  final bool use24hFormat;

  /// Minute interval step.
  final int minuteStep;

  /// Underlying date controller.
  final WheelDateController date;

  /// Underlying time controller.
  final WheelTimeController time;

  ValueChanged<DateTime>? _onChanged;
  final ValueNotifier<DateTime> _valueNotifier;

  /// The currently selected date and time.
  DateTime get value => _valueNotifier.value;

  /// Read-only listenable for the current [DateTime].
  ValueListenable<DateTime> get valueListenable => _valueNotifier;

  void _initSync() {
    void emitChange() {
      final d = date.value;
      final t = time.value;
      final newDt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      _valueNotifier.value = newDt;
      _onChanged?.call(newDt);
    }

    date.valueListenable.addListener(emitChange);
    time.valueListenable.addListener(emitChange);
  }

  /// Updates the onChanged callback.
  void setOnChanged(ValueChanged<DateTime>? f) => _onChanged = f;

  /// Jumps both date and time wheels to the provided [dt].
  void jumpToDateTime(DateTime dt, {bool notify = true}) {
    date.jumpToDate(dt, notify: false);
    time.jumpToTime(TimeOfDay.fromDateTime(dt), notify: false);
    _valueNotifier.value = dt;
    if (notify) {
      _onChanged?.call(dt);
    }
  }

  /// Animates both date and time wheels to the provided [dt].
  Future<void> animateToDateTime(
    DateTime dt, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
    bool notify = true,
  }) async {
    await Future.wait([
      date.animateToDate(dt, duration: duration, curve: curve, notify: false),
      time.animateToTime(TimeOfDay.fromDateTime(dt), duration: duration, curve: curve, notify: false),
    ]);
    _valueNotifier.value = dt;
    if (notify) {
      _onChanged?.call(dt);
    }
  }

  /// Disposes date, time, and unified notifiers.
  void dispose() {
    _valueNotifier.dispose();
    date.dispose();
    time.dispose();
  }
}
