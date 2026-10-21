import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/date/builder.dart';
import 'package:wheel_choice_ext/src/date/flex.dart';
import 'package:wheel_choice_ext/src/date/header.dart';
import 'package:wheel_choice_ext/src/date/label.dart';
import 'package:wheel_choice_ext/src/date/order.dart';
import 'choice.dart';
import 'controller.dart';

/// A [FormField] that contains a [WheelDateRangeChoice].
class WheelDateRangeChoiceFormField extends FormField<DateTimeRange> {
  /// Creates a [FormField] containing a [WheelDateRangeChoice].
  WheelDateRangeChoiceFormField({
    super.key,
    this.controller,
    DateTimeRange? initialValue,
    ValueChanged<DateTimeRange>? onChanged,
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
    Widget? startHeader,
    Widget? endHeader,
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
          builder: (FormFieldState<DateTimeRange> field) {
            final effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            void handleChanged(DateTimeRange value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            final effectivePhysics =
                enabled ? physics : const NeverScrollableScrollPhysics();

            Widget wheel;
            if (controller != null) {
              wheel = WheelDateRangeChoice.raw(
                controller: controller,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                dateBuilder: dateBuilder,
                dateLabel: dateLabel,
                dateFlex: dateFlex,
                dateHeader: dateHeader,
                dateOrder: dateOrder,
                startHeader: startHeader,
                endHeader: endHeader,
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
              wheel = WheelDateRangeChoice(
                value: field.value,
                onChanged: enabled ? handleChanged : null,
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
                startHeader: startHeader,
                endHeader: endHeader,
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

  /// External date range controller.
  final WheelDateRangeController? controller;

  @override
  FormFieldState<DateTimeRange> createState() =>
      _WheelDateRangeChoiceFormFieldState();
}

class _WheelDateRangeChoiceFormFieldState
    extends FormFieldState<DateTimeRange> {
  @override
  WheelDateRangeChoiceFormField get widget =>
      super.widget as WheelDateRangeChoiceFormField;

  @override
  void initState() {
    super.initState();
    widget.controller?.valueListenable.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(WheelDateRangeChoiceFormField oldWidget) {
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
      widget.controller!.jumpToRange(widget.initialValue!);
    }
  }
}
