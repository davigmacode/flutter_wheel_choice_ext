import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/common/types.dart';
import 'package:wheel_choice_ext/src/date/builder.dart';
import 'package:wheel_choice_ext/src/date/flex.dart';
import 'package:wheel_choice_ext/src/date/header.dart';
import 'package:wheel_choice_ext/src/date/label.dart';
import 'package:wheel_choice_ext/src/date/order.dart';
import 'package:wheel_choice_ext/src/time/builder.dart';
import 'package:wheel_choice_ext/src/time/flex.dart';
import 'package:wheel_choice_ext/src/time/header.dart';
import 'package:wheel_choice_ext/src/time/label.dart';
import 'choice.dart';
import 'controller.dart';

/// A [FormField] that contains a [WheelDateTimeChoice].
class WheelDateTimeChoiceFormField extends FormField<DateTime> {
  /// Creates a [FormField] containing a [WheelDateTimeChoice].
  WheelDateTimeChoiceFormField({
    super.key,
    this.controller,
    DateTime? initialValue,
    bool use24hFormat = true,
    int minuteStep = 1,
    ValueChanged<DateTime>? onChanged,
    ValueTransformer<DateTime, bool>? disableDate,
    DateTime? minDate,
    DateTime? maxDate,
    int? minYear,
    int? maxYear,
    int? radiusYear,
    int? anchorYear,
    bool? loop,
    double? itemExtent,
    int? itemVisible,
    WheelDateBuilder? dateBuilder,
    WheelDateLabel? dateLabel,
    WheelDateFlex? dateFlex,
    WheelDateHeader? dateHeader,
    WheelDateOrder? dateOrder,
    WheelTimeBuilder? timeBuilder,
    WheelTimeLabel? timeLabel,
    WheelTimeFlex? timeFlex,
    WheelTimeHeader? timeHeader,
    WidgetBuilder? overlay,
    WheelEffect? effect,
    double? spacing,
    Widget? separator,
    ScrollPhysics? physics,
    Clip? clipBehavior,
    bool? keyboard,
    FocusNode? focusNode,
    bool? haptics,
    InputDecoration? decoration,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled = true,
    super.restorationId,
  }) : super(
          initialValue: controller != null ? controller.value : initialValue,
          builder: (FormFieldState<DateTime> field) {
            final effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            void handleChanged(DateTime value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            final effectivePhysics =
                enabled ? physics : const NeverScrollableScrollPhysics();

            Widget wheel;
            if (controller != null) {
              wheel = WheelDateTimeChoice.raw(
                controller: controller,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                dateBuilder: dateBuilder,
                dateLabel: dateLabel,
                dateFlex: dateFlex,
                dateHeader: dateHeader,
                dateOrder: dateOrder,
                timeBuilder: timeBuilder,
                timeLabel: timeLabel,
                timeFlex: timeFlex,
                timeHeader: timeHeader,
                overlay: overlay,
                effect: effect,
                spacing: spacing,
                separator: separator,
                physics: effectivePhysics,
                clipBehavior: clipBehavior,
                keyboard: enabled ? keyboard : false,
                focusNode: focusNode,
                haptics: enabled ? haptics : false,
              );
            } else {
              wheel = WheelDateTimeChoice(
                value: field.value,
                use24hFormat: use24hFormat,
                minuteStep: minuteStep,
                onChanged: enabled ? handleChanged : null,
                disableDate: disableDate,
                minDate: minDate,
                maxDate: maxDate,
                minYear: minYear,
                maxYear: maxYear,
                radiusYear: radiusYear,
                anchorYear: anchorYear,
                loop: loop,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                dateBuilder: dateBuilder,
                dateLabel: dateLabel,
                dateFlex: dateFlex,
                dateHeader: dateHeader,
                dateOrder: dateOrder,
                timeBuilder: timeBuilder,
                timeLabel: timeLabel,
                timeFlex: timeFlex,
                timeHeader: timeHeader,
                overlay: overlay,
                effect: effect,
                spacing: spacing,
                separator: separator,
                physics: effectivePhysics,
                clipBehavior: clipBehavior,
                keyboard: enabled ? keyboard : false,
                focusNode: focusNode,
                haptics: enabled ? haptics : false,
              );
            }

            return InputDecorator(
              decoration: effectiveDecoration.copyWith(
                errorText: field.errorText,
                enabled: enabled,
              ),
              isEmpty: field.value == null,
              child: wheel,
            );
          },
        );

  /// External unified controller.
  final WheelDateTimeController? controller;

  @override
  FormFieldState<DateTime> createState() => _WheelDateTimeChoiceFormFieldState();
}

class _WheelDateTimeChoiceFormFieldState extends FormFieldState<DateTime> {
  @override
  WheelDateTimeChoiceFormField get widget =>
      super.widget as WheelDateTimeChoiceFormField;

  @override
  void initState() {
    super.initState();
    widget.controller?.valueListenable.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(WheelDateTimeChoiceFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.valueListenable
          .removeListener(_handleControllerChanged);
      widget.controller?.valueListenable.addListener(_handleControllerChanged);
      if (widget.controller != null) {
        setValue(widget.controller!.value);
      }
    }
  }

  @override
  void dispose() {
    widget.controller?.valueListenable.removeListener(_handleControllerChanged);
    super.dispose();
  }

  void _handleControllerChanged() {
    if (widget.controller != null && widget.controller!.value != value) {
      didChange(widget.controller!.value);
    }
  }

  @override
  void reset() {
    super.reset();
    if (widget.controller != null && widget.initialValue != null) {
      widget.controller!.jumpToDateTime(widget.initialValue!);
    }
  }
}
