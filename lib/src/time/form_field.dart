import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'builder.dart';
import 'choice.dart';
import 'controller.dart';
import 'flex.dart';
import 'header.dart';
import 'label.dart';

/// A [FormField] that contains a [WheelTimeChoice].
///
/// Integrates [WheelTimeChoice] with Flutter's [Form] architecture,
/// providing automatic validation, error message rendering, [onSaved],
/// and form reset support.
class WheelTimeChoiceFormField extends FormField<TimeOfDay> {
  /// Creates a [FormField] containing a [WheelTimeChoice].
  WheelTimeChoiceFormField({
    super.key,
    this.controller,
    TimeOfDay? initialValue,
    bool use24hFormat = true,
    int minuteStep = 1,
    ValueChanged<TimeOfDay>? onChanged,
    bool? loop,
    double? itemExtent,
    int? itemVisible,
    WheelTimeBuilder? itemBuilder,
    WheelTimeLabel? itemLabel,
    WheelTimeFlex? flex,
    bool? expanded,
    WheelTimeHeader? header,
    WidgetBuilder? overlay,
    WheelEffect? effect,
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
          builder: (FormFieldState<TimeOfDay> field) {
            final effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            void handleChanged(TimeOfDay value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            final effectivePhysics =
                enabled ? physics : const NeverScrollableScrollPhysics();

            Widget wheel;
            if (controller != null) {
              wheel = WheelTimeChoice.raw(
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
                spacing: spacing,
                physics: effectivePhysics,
                clipBehavior: clipBehavior,
                keyboard: enabled ? keyboard : false,
                focusNode: focusNode,
                haptics: enabled ? haptics : false,
              );
            } else {
              wheel = WheelTimeChoice(
                value: field.value,
                use24hFormat: use24hFormat,
                minuteStep: minuteStep,
                onChanged: enabled ? handleChanged : null,
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

  /// Optional external controller for the time wheel picker.
  final WheelTimeController? controller;

  @override
  FormFieldState<TimeOfDay> createState() => _WheelTimeChoiceFormFieldState();
}

class _WheelTimeChoiceFormFieldState extends FormFieldState<TimeOfDay> {
  @override
  WheelTimeChoiceFormField get widget =>
      super.widget as WheelTimeChoiceFormField;

  @override
  void initState() {
    super.initState();
    widget.controller?.valueListenable.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(WheelTimeChoiceFormField oldWidget) {
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
      widget.controller!.jumpToTime(widget.initialValue!);
    }
  }
}
