import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'types.dart';

/// Controller to programmatically manipulate a composite time wheel
/// (hour, minute, optional AM/PM period) using underlying [WheelController]s.
class WheelTimeController {
  /// Creates a controller for time wheels.
  WheelTimeController({
    required TimeOfDay value,
    this.use24hFormat = true,
    this.minuteStep = 1,
    ValueChanged<TimeOfDay>? onChanged,
    bool? loop,
  })  : initialValue = value,
        _onChanged = onChanged,
        _valueNotifier = ValueNotifier<TimeOfDay>(value),
        hour = WheelController<int>(
          value: use24hFormat
              ? value.hour
              : _hourTo12(value.hour),
          options: use24hFormat ? create24HourOptions() : create12HourOptions(),
          loop: loop ?? true,
        ),
        minute = WheelController<int>(
          value: _nearestStep(value.minute, minuteStep),
          options: createMinuteOptions(step: minuteStep),
          loop: loop ?? true,
        ),
        period = use24hFormat
            ? null
            : WheelController<WheelTimePeriod>(
                value: _hourToPeriod(value.hour),
                options: const [WheelTimePeriod.am, WheelTimePeriod.pm],
                loop: false,
              ) {
    _handleValueChanged();
  }

  /// Initial value configured at creation.
  final TimeOfDay initialValue;

  /// Whether the picker operates in 24-hour mode (0..23) or 12-hour mode (1..12 + AM/PM).
  final bool use24hFormat;

  /// Minute interval step (must divide 60 evenly, e.g. 1, 5, 10, 15).
  final int minuteStep;

  /// Controller for hour wheel.
  final WheelController<int> hour;

  /// Controller for minute wheel.
  final WheelController<int> minute;

  /// Controller for period wheel (null in 24-hour mode).
  final WheelController<WheelTimePeriod>? period;

  ValueChanged<TimeOfDay>? _onChanged;
  final ValueNotifier<TimeOfDay> _valueNotifier;

  /// The currently selected time.
  TimeOfDay get value => _valueNotifier.value;

  /// Read-only listenable for the current time.
  ValueListenable<TimeOfDay> get valueListenable => _valueNotifier;

  /// 12-hour options: 1..12
  static List<int> create12HourOptions() => [for (var i = 1; i <= 12; i++) i];

  /// 24-hour options: 0..23
  static List<int> create24HourOptions() => [for (var i = 0; i < 24; i++) i];

  /// Minute options: 0..59 with specified [step].
  static List<int> createMinuteOptions({int step = 1}) {
    final s = step <= 0 ? 1 : step;
    return [for (var i = 0; i < 60; i += s) i];
  }

  static int _nearestStep(int minute, int step) {
    if (step <= 1) return minute;
    final options = createMinuteOptions(step: step);
    if (options.contains(minute)) return minute;
    var nearest = options.first;
    var minDiff = (minute - nearest).abs();
    for (final opt in options) {
      final diff = (minute - opt).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = opt;
      }
    }
    return nearest;
  }

  static int _hourTo12(int hour24) {
    final h = hour24 % 12;
    return h == 0 ? 12 : h;
  }

  static WheelTimePeriod _hourToPeriod(int hour24) {
    return hour24 >= 12 ? WheelTimePeriod.pm : WheelTimePeriod.am;
  }

  static int _to24Hour(int hour12, WheelTimePeriod p) {
    final isPm = p == WheelTimePeriod.pm;
    if (hour12 == 12) {
      return isPm ? 12 : 0;
    }
    return isPm ? hour12 + 12 : hour12;
  }

  /// Updates the onChanged callback.
  void setOnChanged(ValueChanged<TimeOfDay>? f) => _onChanged = f;

  /// Jumps wheels to the provided [time] without animation.
  void jumpToTime(TimeOfDay time, {bool notify = true}) {
    if (use24hFormat) {
      hour.jumpToValue(time.hour, notify: notify);
    } else {
      hour.jumpToValue(_hourTo12(time.hour), notify: notify);
      period?.jumpToValue(_hourToPeriod(time.hour), notify: notify);
    }
    minute.jumpToValue(_nearestStep(time.minute, minuteStep), notify: notify);
    _valueNotifier.value = time;
    if (notify) {
      _onChanged?.call(time);
    }
  }

  /// Animates wheels to the provided [time].
  Future<void> animateToTime(
    TimeOfDay time, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
    bool notify = true,
  }) async {
    final futures = <Future<void>>[];
    if (use24hFormat) {
      futures.add(hour.animateToValue(
        time.hour,
        duration: duration,
        curve: curve,
        notify: notify,
      ));
    } else {
      futures.add(hour.animateToValue(
        _hourTo12(time.hour),
        duration: duration,
        curve: curve,
        notify: notify,
      ));
      if (period != null) {
        futures.add(period!.animateToValue(
          _hourToPeriod(time.hour),
          duration: duration,
          curve: curve,
          notify: notify,
        ));
      }
    }
    futures.add(minute.animateToValue(
      _nearestStep(time.minute, minuteStep),
      duration: duration,
      curve: curve,
      notify: notify,
    ));

    await Future.wait(futures);
    _valueNotifier.value = time;
    if (notify) {
      _onChanged?.call(time);
    }
  }

  /// Moves the hour wheel to the next item if available.
  Future<bool> nextHour({
    bool animate = true,
    Duration? duration,
    Curve? curve,
  }) =>
      hour.next(animate: animate, duration: duration, curve: curve);

  /// Moves the hour wheel to the previous item if available.
  Future<bool> previousHour({
    bool animate = true,
    Duration? duration,
    Curve? curve,
  }) =>
      hour.previous(animate: animate, duration: duration, curve: curve);

  /// Moves the minute wheel to the next item if available.
  Future<bool> nextMinute({
    bool animate = true,
    Duration? duration,
    Curve? curve,
  }) =>
      minute.next(animate: animate, duration: duration, curve: curve);

  /// Moves the minute wheel to the previous item if available.
  Future<bool> previousMinute({
    bool animate = true,
    Duration? duration,
    Curve? curve,
  }) =>
      minute.previous(animate: animate, duration: duration, curve: curve);

  /// Toggles between AM and PM in 12-hour mode.
  Future<bool> togglePeriod({
    bool animate = true,
    Duration? duration,
    Curve? curve,
  }) {
    if (period == null) return Future.value(false);
    final target = period!.value == WheelTimePeriod.am
        ? WheelTimePeriod.pm
        : WheelTimePeriod.am;
    return period!.setValue(
      target,
      animate: animate,
      duration: duration,
      curve: curve,
    );
  }

  void _handleValueChanged() {
    void emitChange() {
      final int resolvedHour;
      if (use24hFormat) {
        resolvedHour = hour.value ?? initialValue.hour;
      } else {
        final h12 = hour.value ?? _hourTo12(initialValue.hour);
        final p = period?.value ?? _hourToPeriod(initialValue.hour);
        resolvedHour = _to24Hour(h12, p);
      }
      final resolvedMinute = minute.value ?? initialValue.minute;
      final newTime = TimeOfDay(hour: resolvedHour, minute: resolvedMinute);
      _valueNotifier.value = newTime;
      _onChanged?.call(newTime);
    }

    hour.setOnChanged((_) => emitChange());
    minute.setOnChanged((_) => emitChange());
    period?.setOnChanged((_) => emitChange());
  }

  /// Disposes the underlying notifiers and controllers.
  void dispose() {
    _valueNotifier.dispose();
    hour.dispose();
    minute.dispose();
    period?.dispose();
  }
}
