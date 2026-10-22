import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/cascade/choice.dart';
import 'package:wheel_choice_ext/src/cascade/controller.dart';
import 'package:wheel_choice_ext/src/cascade/types.dart';
import 'package:wheel_choice_ext/src/date/choice.dart';
import 'package:wheel_choice_ext/src/date/controller.dart';
import 'package:wheel_choice_ext/src/date/order.dart';
import 'package:wheel_choice_ext/src/datetime/choice.dart';
import 'package:wheel_choice_ext/src/datetime/controller.dart';
import 'package:wheel_choice_ext/src/duration/choice.dart';
import 'package:wheel_choice_ext/src/duration/controller.dart';
import 'package:wheel_choice_ext/src/time/choice.dart';
import 'package:wheel_choice_ext/src/time/controller.dart';

/// Shows a generic wheel picker inside a standard bottom modal sheet with Cancel and Done actions.
Future<T?> showWheelModalSheet<T>({
  required BuildContext context,
  required Widget Function(BuildContext context, void Function(T) onSelected) builder,
  String? title,
  String confirmText = 'Done',
  String cancelText = 'Cancel',
  Color? backgroundColor,
  ShapeBorder? shape,
  bool useRootNavigator = false,
  bool isDismissible = true,
  bool enableDrag = true,
}) {
  T? selectedValue;

  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
    shape: shape ??
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Cancel, optional Title, and Done
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(null),
                    child: Text(cancelText),
                  ),
                  if (title != null)
                    Text(
                      title,
                      style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(selectedValue),
                    child: Text(
                      confirmText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // Wheel builder
              builder(sheetContext, (val) => selectedValue = val),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  );
}

/// Convenience modal picker for calendar date.
Future<DateTime?> showWheelDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? minDate,
  DateTime? maxDate,
  int? minYear,
  int? maxYear,
  WheelDateOrder? order,
  String? title = 'Select Date',
  String confirmText = 'Done',
  String cancelText = 'Cancel',
}) {
  final date = initialDate ?? DateTime.now();
  late final WheelDateController ctrl;
  DateTime tempDate = date;

  return showWheelModalSheet<DateTime>(
    context: context,
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    builder: (sheetContext, onSelected) {
      onSelected(tempDate);
      ctrl = WheelDateController(
        value: date,
        minDate: minDate,
        maxDate: maxDate,
        minYear: minYear,
        maxYear: maxYear,
        onChanged: (d) {
          tempDate = d;
          onSelected(d);
        },
      );

      return WheelDateChoice.raw(
        controller: ctrl,
        order: order ?? WheelDateOrder.of(sheetContext),
        itemExtent: 44,
        itemVisible: 5,
        spacing: 8,
      );
    },
  );
}

/// Convenience modal picker for time of day.
Future<TimeOfDay?> showWheelTimePicker({
  required BuildContext context,
  TimeOfDay? initialTime,
  bool use24hFormat = true,
  int minuteStep = 1,
  String? title = 'Select Time',
  String confirmText = 'Done',
  String cancelText = 'Cancel',
}) {
  final time = initialTime ?? TimeOfDay.now();
  late final WheelTimeController ctrl;
  TimeOfDay tempTime = time;

  return showWheelModalSheet<TimeOfDay>(
    context: context,
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    builder: (sheetContext, onSelected) {
      onSelected(tempTime);
      ctrl = WheelTimeController(
        value: time,
        use24hFormat: use24hFormat,
        minuteStep: minuteStep,
        onChanged: (t) {
          tempTime = t;
          onSelected(t);
        },
      );

      return WheelTimeChoice.raw(
        controller: ctrl,
        itemExtent: 44,
        itemVisible: 5,
        spacing: 8,
      );
    },
  );
}

/// Convenience modal picker for date and time combined.
Future<DateTime?> showWheelDateTimePicker({
  required BuildContext context,
  DateTime? initialDateTime,
  bool use24hFormat = true,
  int minuteStep = 1,
  WheelDateOrder? dateOrder,
  String? title = 'Select Date & Time',
  String confirmText = 'Done',
  String cancelText = 'Cancel',
}) {
  final dt = initialDateTime ?? DateTime.now();
  late final WheelDateTimeController ctrl;
  DateTime tempDt = dt;

  return showWheelModalSheet<DateTime>(
    context: context,
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    builder: (sheetContext, onSelected) {
      onSelected(tempDt);
      ctrl = WheelDateTimeController(
        value: dt,
        use24hFormat: use24hFormat,
        minuteStep: minuteStep,
        onChanged: (newDt) {
          tempDt = newDt;
          onSelected(newDt);
        },
      );

      return WheelDateTimeChoice.raw(
        controller: ctrl,
        dateOrder: dateOrder ?? WheelDateOrder.of(sheetContext),
        itemExtent: 44,
        itemVisible: 5,
        spacing: 6,
      );
    },
  );
}

/// Convenience modal picker for duration.
Future<Duration?> showWheelDurationPicker({
  required BuildContext context,
  Duration? initialDuration,
  int maxDays = 30,
  int maxHours = 23,
  int dayStep = 1,
  int minuteStep = 1,
  int secondStep = 1,
  bool showDays = false,
  bool showHours = true,
  bool showMinutes = true,
  bool showSeconds = true,
  String? title = 'Select Duration',
  String confirmText = 'Done',
  String cancelText = 'Cancel',
}) {
  final dur = initialDuration ?? Duration.zero;
  late final WheelDurationController ctrl;
  Duration tempDur = dur;

  return showWheelModalSheet<Duration>(
    context: context,
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    builder: (sheetContext, onSelected) {
      onSelected(tempDur);
      ctrl = WheelDurationController(
        value: dur,
        maxDays: maxDays,
        maxHours: maxHours,
        dayStep: dayStep,
        minuteStep: minuteStep,
        secondStep: secondStep,
        showDays: showDays,
        showHours: showHours,
        showMinutes: showMinutes,
        showSeconds: showSeconds,
        onChanged: (newDur) {
          tempDur = newDur;
          onSelected(newDur);
        },
      );

      return WheelDurationChoice.raw(
        controller: ctrl,
        itemExtent: 44,
        itemVisible: 5,
        spacing: 8,
      );
    },
  );
}

/// Convenience modal picker for cascading hierarchical choices.
Future<List<T>?> showWheelCascadePicker<T>({
  required BuildContext context,
  List<WheelCascadeItem<T>> items = const [],
  WheelCascadeOptionsLoader<T>? optionsLoader,
  int? depth,
  List<T>? initialValue,
  List<Widget?>? header,
  List<int>? flex,
  double itemExtent = 44,
  int itemVisible = 5,
  double spacing = 8,
  WheelItemLabel<T>? itemLabel,
  String? title = 'Select Options',
  String confirmText = 'Done',
  String cancelText = 'Cancel',
}) {
  late final WheelCascadeController<T> ctrl;
  List<T> tempVal = initialValue ?? [];

  return showWheelModalSheet<List<T>>(
    context: context,
    title: title,
    confirmText: confirmText,
    cancelText: cancelText,
    builder: (sheetContext, onSelected) {
      ctrl = WheelCascadeController<T>(
        items: items.isNotEmpty ? items : null,
        optionsLoader: optionsLoader,
        depth: depth,
        initialValue: initialValue,
        onChanged: (newVal) {
          tempVal = newVal;
          onSelected(newVal);
        },
      );
      if (tempVal.isNotEmpty) {
        onSelected(tempVal);
      }

      return WheelCascadeChoice<T>.raw(
        controller: ctrl,
        header: header,
        flex: flex,
        itemExtent: itemExtent,
        itemVisible: itemVisible,
        spacing: spacing,
        itemLabel: itemLabel,
      );
    },
  );
}

