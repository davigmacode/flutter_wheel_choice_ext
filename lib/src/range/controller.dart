import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wheel_choice_ext/src/date/controller.dart';

/// Controller to programmatically manipulate a date range wheel (start date, end date).
class WheelDateRangeController {
  /// Creates a controller for date range wheels.
  WheelDateRangeController({
    required DateTimeRange value,
    ValueChanged<DateTimeRange>? onChanged,
    int? minYear,
    int? maxYear,
    int? radiusYear,
    int? anchorYear,
    bool? loop,
  })  : initialValue = value,
        _onChanged = onChanged,
        _valueNotifier = ValueNotifier<DateTimeRange>(value),
        start = WheelDateController(
          value: value.start,
          minYear: minYear,
          maxYear: maxYear,
          radiusYear: radiusYear,
          anchorYear: anchorYear,
          loop: loop,
        ),
        end = WheelDateController(
          value: value.end,
          minYear: minYear,
          maxYear: maxYear,
          radiusYear: radiusYear,
          anchorYear: anchorYear,
          loop: loop,
        ) {
    _initSync();
  }

  /// Initial range value.
  final DateTimeRange initialValue;

  /// Controller for the start date wheel.
  final WheelDateController start;

  /// Controller for the end date wheel.
  final WheelDateController end;

  ValueChanged<DateTimeRange>? _onChanged;
  final ValueNotifier<DateTimeRange> _valueNotifier;

  /// Current selected date range.
  DateTimeRange get value => _valueNotifier.value;

  /// Read-only listenable for the date range.
  ValueListenable<DateTimeRange> get valueListenable => _valueNotifier;

  void _initSync() {
    start.valueListenable.addListener(() {
      if (end.value.isBefore(start.value)) {
        end.jumpToDate(start.value, notify: false);
      }
      _emitChange();
    });

    end.valueListenable.addListener(() {
      if (start.value.isAfter(end.value)) {
        start.jumpToDate(end.value, notify: false);
      }
      _emitChange();
    });
  }

  void _emitChange() {
    final range = DateTimeRange(start: start.value, end: end.value);
    _valueNotifier.value = range;
    _onChanged?.call(range);
  }

  /// Updates the onChanged callback.
  void setOnChanged(ValueChanged<DateTimeRange>? f) => _onChanged = f;

  /// Jumps both wheels to the provided [range].
  void jumpToRange(DateTimeRange range, {bool notify = true}) {
    start.jumpToDate(range.start, notify: false);
    end.jumpToDate(range.end, notify: false);
    _valueNotifier.value = range;
    if (notify) {
      _onChanged?.call(range);
    }
  }

  /// Disposes controllers and notifiers.
  void dispose() {
    _valueNotifier.dispose();
    start.dispose();
    end.dispose();
  }
}
