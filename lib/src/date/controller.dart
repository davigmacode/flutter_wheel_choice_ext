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
    this.onChanged,
    this.disableDate,
    DateTime? minDate,
    DateTime? maxDate,
    int? minYear,
    int? maxYear,
    int? radiusYear,
    int? anchorYear,
    bool? loop,
  }) : initialValue = value,
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
    _configureControllers();
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
  final ValueChanged<DateTime>? onChanged;

  /// Additional date-level disabling. If returns true, the date is disabled.
  final ValueTransformer<DateTime, bool>? disableDate;

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

  void _configureControllers() {
    // Item disabling rules based on current selections
    day.setItemDisabled(
      (int d) => isDisabledDay(
        d,
        year: year.value ?? initialValue.year,
        month: month.value ?? initialValue.month,
      ),
    );
    month.setItemDisabled(
      (int m) => isDisabledMonth(
        m,
        year: year.value ?? initialValue.year,
        day: day.value ?? initialValue.day,
      ),
    );
    year.setItemDisabled(
      (int y) => isDisabledYear(
        y,
        month: month.value ?? initialValue.month,
        day: day.value ?? initialValue.day,
      ),
    );

    // Change propagation: keep date valid and notify
    day.setOnChanged((int d) {
      final y = year.value ?? initialValue.year;
      final m = month.value ?? initialValue.month;
      if (isValidDate(y, m, d)) {
        onChanged?.call(DateTime(y, m, d));
      }
    });

    month.setOnChanged((int m) {
      final y = year.value ?? initialValue.year;
      var d = day.value ?? initialValue.day;
      if (!isValidDate(y, m, d)) {
        d = 1;
        // Correct the day wheel to a valid day (1)
        day.jumpToValue(d);
      }
      onChanged?.call(DateTime(y, m, d));
    });

    year.setOnChanged((int y) {
      final m = month.value ?? initialValue.month;
      var d = day.value ?? initialValue.day;
      if (!isValidDate(y, m, d)) {
        d = 1;
        day.jumpToValue(d);
      }
      onChanged?.call(DateTime(y, m, d));
    });
  }

  /// Jumps the three wheels to the provided [date] without animation.
  void jumpToDate(DateTime date) {
    day.jumpToValue(date.day);
    month.jumpToValue(date.month);
    year.jumpToValue(date.year);
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

  /// Validates a date against calendar rules and configured boundaries.
  bool isValidDate(int year, int month, int day) {
    try {
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return false;
      }
      if (disableDate?.call(date) == true) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool isDisabledDay(int day, {required int year, required int month}) =>
      !isValidDate(year, month, day);

  bool isDisabledMonth(int month, {required int year, required int day}) =>
      !isValidDate(year, month, day);

  bool isDisabledYear(int year, {required int month, required int day}) {
    return !isValidDate(year, month, day);
  }

  /// Disposes the three underlying controllers.
  void dispose() {
    day.dispose();
    month.dispose();
    year.dispose();
  }
}
