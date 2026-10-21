import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/common/types.dart';
import 'builder.dart';
import 'choice.dart';
import 'controller.dart';
import 'flex.dart';
import 'header.dart';
import 'label.dart';
import 'order.dart';

/// A [FormField] that contains a [WheelDateChoice].
///
/// Integrates [WheelDateChoice] with Flutter's [Form] architecture,
/// providing automatic validation, error message rendering, [onSaved],
/// and form reset support.
class WheelDateChoiceFormField extends FormField<DateTime> {
  /// Creates a [FormField] containing a [WheelDateChoice].
  WheelDateChoiceFormField({
    super.key,
    this.controller,
    DateTime? initialValue,
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
    WheelDateBuilder? itemBuilder,
    WheelDateLabel? itemLabel,
    WheelDateFlex? flex,
    bool? expanded,
    WheelDateHeader? header,
    WidgetBuilder? overlay,
    WheelEffect? effect,
    WheelDateOrder? order,
    double? spacing,
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
              wheel = WheelDateChoice.raw(
                controller: controller,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                itemBuilder: itemBuilder,
                itemLabel: itemLabel,
                flex: flex,
                expanded: expanded,
                header: header,
                overlay: overlay,
                effect: effect,
                order: order,
                spacing: spacing,
                physics: effectivePhysics,
                clipBehavior: clipBehavior,
                keyboard: enabled ? keyboard : false,
                focusNode: focusNode,
                haptics: enabled ? haptics : false,
              );
            } else {
              wheel = WheelDateChoice(
                value: field.value,
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
                itemBuilder: itemBuilder,
                itemLabel: itemLabel,
                flex: flex,
                expanded: expanded,
                header: header,
                overlay: overlay,
                effect: effect,
                order: order,
                spacing: spacing,
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

  /// Optional external controller for the date wheel picker.
  final WheelDateController? controller;

  @override
  FormFieldState<DateTime> createState() => _WheelDateChoiceFormFieldState();
}

class _WheelDateChoiceFormFieldState extends FormFieldState<DateTime> {
  @override
  WheelDateChoiceFormField get widget =>
      super.widget as WheelDateChoiceFormField;

  @override
  void initState() {
    super.initState();
    widget.controller?.valueListenable.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(WheelDateChoiceFormField oldWidget) {
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
      widget.controller!.jumpToDate(widget.initialValue!);
    }
  }
}
