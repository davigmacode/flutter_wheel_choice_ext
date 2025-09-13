import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/common/types.dart';

/// Controller to programmatically manipulate a composite date wheel
/// (day, month, year) using three underlying [WheelController]s.
class WheelDateController {
  /// Creates a controller for day, month, and year wheels.
  ///
  /// If any controller is not provided, a new instance is created.
  /// You can also configure boundaries, disabled-date logic, and looping.
  WheelDateController({
    required DateTime value,
    ValueChanged<DateTime>? onChanged,
    ValueTransformer<DateTime, bool>? disableDate,
    DateTime? minDate,
    DateTime? maxDate,
    int? minYear,
    int? maxYear,
    int? radiusYear,
    int? anchorYear,
    bool? loop,
  }) : initialValue = value,
       _onChanged = onChanged,
       _disableDate = disableDate,
       day = WheelController<int>(
         value: value.day,
         options: createDayOptions(),
         loop: loop,
       ),
       month = WheelController<int>(
         value: value.month,
         options: createMonthOptions(),
         loop: loop,
       ),
       year = WheelController<int>(
         value: value.year,
         options: createYearOptions(
           minDate: minDate,
           maxDate: maxDate,
           minYear: minYear,
           maxYear: maxYear,
           radiusYear: radiusYear,
           anchorYear: anchorYear,
         ),
         loop: loop,
       ) {
    _handleDisableDate();
    _handleValueChanged();
  }

  /// Controller for day wheel (1..31, depending on month/year).
  final WheelController<int> day;

  /// Controller for month wheel (1..12).
  final WheelController<int> month;

  /// Controller for year wheel.
  final WheelController<int> year;

  /// Initial value that consumers may use for initial selection.
  final DateTime initialValue;

  /// Emits whenever a full date is committed by the consumer.
  ValueChanged<DateTime>? _onChanged;

  /// Additional date-level disabling. If returns true, the date is disabled.
  ValueTransformer<DateTime, bool>? _disableDate;

  /// Year options constrained by [minYear]/[maxYear] and [minDate]/[maxDate].
  static List<int> createYearOptions({
    DateTime? minDate,
    DateTime? maxDate,
    int? minYear,
    int? maxYear,
    int? radiusYear,
    int? anchorYear,
  }) {
    radiusYear ??= 20;
    anchorYear ??= DateTime.now().year;
    final min = minYear ?? minDate?.year ?? (anchorYear - radiusYear);
    final max = maxYear ?? maxDate?.year ?? (anchorYear + radiusYear);
    return List.generate(max - min + 1, (i) => min + i);
  }

  /// Month options: 1..12
  static List<int> createMonthOptions() => List.generate(12, (i) => i + 1);

  /// Day options: 1..31 (validity is checked separately).
  static List<int> createDayOptions() => List.generate(31, (i) => i + 1);

  void setOptions({
    DateTime? minDate,
    DateTime? maxDate,
    int? minYear,
    int? maxYear,
    int? radiusYear,
    int? anchorYear,
    bool alignToValue = true,
    bool animate = false,
    Duration? duration,
    Curve? curve,
  }) {
    day.setOptions(
      createDayOptions(),
      alignToValue: alignToValue,
      animate: animate,
      duration: duration,
    );
    month.setOptions(
      createMonthOptions(),
      alignToValue: alignToValue,
      animate: animate,
      duration: duration,
    );
    year.setOptions(
      createYearOptions(
        minDate: minDate,
        maxDate: maxDate,
        minYear: minYear,
        maxYear: maxYear,
        radiusYear: radiusYear,
        anchorYear: anchorYear,
      ),
      alignToValue: alignToValue,
      animate: animate,
      duration: duration,
    );
  }

  /// Updates the disableDate resolver.
  void setDisableDate(ValueTransformer<DateTime, bool>? f) => _disableDate = f;

  /// Updates the onChanged callback.
  void setOnChanged(ValueChanged<DateTime>? f) => _onChanged = f;

  void setLoop(bool? v) {
    day.setLoop(v);
    month.setLoop(v);
    year.setLoop(v);
  }

  /// Jumps the three wheels to the provided [date] without animation.
  void jumpToDate(DateTime date, {bool notify = true}) {
    day.jumpToValue(date.day, notify: notify);
    month.jumpToValue(date.month, notify: notify);
    year.jumpToValue(date.year, notify: notify);
  }

  /// Animates the three wheels to the provided [date].
  Future<void> animateToDate(
    DateTime date, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.ease,
  }) async {
    await Future.wait([
      day.animateToValue(date.day, duration: duration, curve: curve),
      month.animateToValue(date.month, duration: duration, curve: curve),
      year.animateToValue(date.year, duration: duration, curve: curve),
    ]);
  }

  void _handleDisableDate() {
    // Item disabling rules based on current selections
    day.setItemDisabled(
      (int d) => _isDisabledDay(
        d,
        year: year.value ?? initialValue.year,
        month: month.value ?? initialValue.month,
      ),
    );
    month.setItemDisabled(
      (int m) => _isDisabledMonth(
        m,
        year: year.value ?? initialValue.year,
        day: day.value ?? initialValue.day,
      ),
    );
    year.setItemDisabled(
      (int y) => _isDisabledYear(
        y,
        month: month.value ?? initialValue.month,
        day: day.value ?? initialValue.day,
      ),
    );
  }

  void _handleValueChanged() {
    // Change propagation: keep date valid and notify
    day.setOnChanged((int d) {
      final y = year.value ?? initialValue.year;
      final m = month.value ?? initialValue.month;
      if (_isValidDate(y, m, d)) {
        _onChanged?.call(DateTime(y, m, d));
      }
    });

    month.setOnChanged((int m) {
      final y = year.value ?? initialValue.year;
      var d = day.value ?? initialValue.day;
      if (!_isValidDate(y, m, d)) {
        d = 1;
        // Correct the day wheel to a valid day (1)
        day.jumpToValue(d);
      }
      _onChanged?.call(DateTime(y, m, d));
    });

    year.setOnChanged((int y) {
      final m = month.value ?? initialValue.month;
      var d = day.value ?? initialValue.day;
      if (!_isValidDate(y, m, d)) {
        d = 1;
        day.jumpToValue(d);
      }
      _onChanged?.call(DateTime(y, m, d));
    });
  }

  /// Validates a date against calendar rules and configured boundaries.
  bool _isValidDate(int year, int month, int day) {
    try {
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return false;
      }
      if (_disableDate?.call(date) == true) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isDisabledDay(int day, {required int year, required int month}) =>
      !_isValidDate(year, month, day);

  bool _isDisabledMonth(int month, {required int year, required int day}) =>
      !_isValidDate(year, month, day);

  bool _isDisabledYear(int year, {required int month, required int day}) {
    return !_isValidDate(year, month, day);
  }

  /// Disposes the three underlying controllers.
  void dispose() {
    day.dispose();
    month.dispose();
    year.dispose();
  }
}
