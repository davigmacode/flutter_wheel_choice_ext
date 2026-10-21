import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:wheel_choice/wheel_choice.dart';

/// Controller to programmatically manipulate a duration wheel (hours, minutes, seconds).
class WheelDurationController {
  /// Creates a controller for duration wheels.
  WheelDurationController({
    required Duration value,
    this.maxHours = 23,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
    ValueChanged<Duration>? onChanged,
    bool? loop,
  })  : initialValue = value,
        _onChanged = onChanged,
        _valueNotifier = ValueNotifier<Duration>(value),
        hours = WheelController<int>(
          value: value.inHours.clamp(0, maxHours),
          options: [for (var i = 0; i <= maxHours; i++) i],
          loop: loop ?? false,
        ),
        minutes = WheelController<int>(
          value: _nearestStep(value.inMinutes % 60, minuteStep),
          options: [for (var i = 0; i < 60; i += (minuteStep <= 0 ? 1 : minuteStep)) i],
          loop: loop ?? true,
        ),
        seconds = WheelController<int>(
          value: _nearestStep(value.inSeconds % 60, secondStep),
          options: [for (var i = 0; i < 60; i += (secondStep <= 0 ? 1 : secondStep)) i],
          loop: loop ?? true,
        ) {
    _handleValueChanged();
  }

  /// Initial duration configured at creation.
  final Duration initialValue;

  /// Maximum selectable hours (e.g. 23, 99).
  final int maxHours;

  /// Minute interval step.
  final int minuteStep;

  /// Second interval step.
  final int secondStep;

  /// Whether to display the hours column.
  final bool showHours;

  /// Whether to display the minutes column.
  final bool showMinutes;

  /// Whether to display the seconds column.
  final bool showSeconds;

  /// Controller for the hours wheel.
  final WheelController<int> hours;

  /// Controller for the minutes wheel.
  final WheelController<int> minutes;

  /// Controller for the seconds wheel.
  final WheelController<int> seconds;

  ValueChanged<Duration>? _onChanged;
  final ValueNotifier<Duration> _valueNotifier;

  /// The currently selected duration.
  Duration get value => _valueNotifier.value;

  /// Read-only listenable for the current duration.
  ValueListenable<Duration> get valueListenable => _valueNotifier;

  static int _nearestStep(int val, int step) {
    if (step <= 1) return val;
    final options = [for (var i = 0; i < 60; i += step) i];
    if (options.contains(val)) return val;
    var nearest = options.first;
    var minDiff = (val - nearest).abs();
    for (final opt in options) {
      final diff = (val - opt).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = opt;
      }
    }
    return nearest;
  }

  /// Updates the onChanged callback.
  void setOnChanged(ValueChanged<Duration>? f) => _onChanged = f;

  /// Jumps wheels to the provided [duration] without animation.
  void jumpToDuration(Duration duration, {bool notify = true}) {
    final h = duration.inHours.clamp(0, maxHours);
    final m = _nearestStep(duration.inMinutes % 60, minuteStep);
    final s = _nearestStep(duration.inSeconds % 60, secondStep);

    if (showHours) hours.jumpToValue(h, notify: notify);
    if (showMinutes) minutes.jumpToValue(m, notify: notify);
    if (showSeconds) seconds.jumpToValue(s, notify: notify);

    final resolved = Duration(
      hours: showHours ? h : 0,
      minutes: showMinutes ? m : 0,
      seconds: showSeconds ? s : 0,
    );
    _valueNotifier.value = resolved;
    if (notify) {
      _onChanged?.call(resolved);
    }
  }

  /// Animates wheels to the provided [duration].
  Future<void> animateToDuration(
    Duration duration, {
    Duration animDuration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
    bool notify = true,
  }) async {
    final h = duration.inHours.clamp(0, maxHours);
    final m = _nearestStep(duration.inMinutes % 60, minuteStep);
    final s = _nearestStep(duration.inSeconds % 60, secondStep);

    final futures = <Future<void>>[];
    if (showHours) {
      futures.add(hours.animateToValue(h, duration: animDuration, curve: curve, notify: notify));
    }
    if (showMinutes) {
      futures.add(minutes.animateToValue(m, duration: animDuration, curve: curve, notify: notify));
    }
    if (showSeconds) {
      futures.add(seconds.animateToValue(s, duration: animDuration, curve: curve, notify: notify));
    }

    await Future.wait(futures);
    final resolved = Duration(
      hours: showHours ? h : 0,
      minutes: showMinutes ? m : 0,
      seconds: showSeconds ? s : 0,
    );
    _valueNotifier.value = resolved;
    if (notify) {
      _onChanged?.call(resolved);
    }
  }

  /// Moves the hours wheel to the next item.
  Future<bool> nextHour({bool animate = true, Duration? duration, Curve? curve}) =>
      hours.next(animate: animate, duration: duration, curve: curve);

  /// Moves the hours wheel to the previous item.
  Future<bool> previousHour({bool animate = true, Duration? duration, Curve? curve}) =>
      hours.previous(animate: animate, duration: duration, curve: curve);

  /// Moves the minutes wheel to the next item.
  Future<bool> nextMinute({bool animate = true, Duration? duration, Curve? curve}) =>
      minutes.next(animate: animate, duration: duration, curve: curve);

  /// Moves the minutes wheel to the previous item.
  Future<bool> previousMinute({bool animate = true, Duration? duration, Curve? curve}) =>
      minutes.previous(animate: animate, duration: duration, curve: curve);

  /// Moves the seconds wheel to the next item.
  Future<bool> nextSecond({bool animate = true, Duration? duration, Curve? curve}) =>
      seconds.next(animate: animate, duration: duration, curve: curve);

  /// Moves the seconds wheel to the previous item.
  Future<bool> previousSecond({bool animate = true, Duration? duration, Curve? curve}) =>
      seconds.previous(animate: animate, duration: duration, curve: curve);

  void _handleValueChanged() {
    void emitChange() {
      final h = showHours ? (hours.value ?? 0) : 0;
      final m = showMinutes ? (minutes.value ?? 0) : 0;
      final s = showSeconds ? (seconds.value ?? 0) : 0;
      final resolved = Duration(hours: h, minutes: m, seconds: s);
      _valueNotifier.value = resolved;
      _onChanged?.call(resolved);
    }

    hours.setOnChanged((_) => emitChange());
    minutes.setOnChanged((_) => emitChange());
    seconds.setOnChanged((_) => emitChange());
  }

  /// Disposes controllers and notifiers.
  void dispose() {
    _valueNotifier.dispose();
    hours.dispose();
    minutes.dispose();
    seconds.dispose();
  }
}
