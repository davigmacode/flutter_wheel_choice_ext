import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'choice.dart';
import 'controller.dart';
import 'header.dart';
import 'label.dart';

/// A [FormField] that contains a [WheelDurationChoice].
class WheelDurationChoiceFormField extends FormField<Duration> {
  /// Creates a [FormField] containing a [WheelDurationChoice].
  WheelDurationChoiceFormField({
    super.key,
    this.controller,
    Duration? initialValue,
    int maxDays = 30,
    int maxHours = 23,
    int dayStep = 1,
    int minuteStep = 1,
    int secondStep = 1,
    bool showDays = false,
    bool showHours = true,
    bool showMinutes = true,
    bool showSeconds = true,
    ValueChanged<Duration>? onChanged,
    bool? loop,
    double? itemExtent,
    int? itemVisible,
    WheelDurationLabel? itemLabel,
    WheelDurationHeader? header,
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
          builder: (FormFieldState<Duration> field) {
            final effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            void handleChanged(Duration value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            final effectivePhysics =
                enabled ? physics : const NeverScrollableScrollPhysics();

            Widget wheel;
            if (controller != null) {
              wheel = WheelDurationChoice.raw(
                controller: controller,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                itemLabel: itemLabel,
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
              wheel = WheelDurationChoice(
                value: field.value,
                maxDays: maxDays,
                maxHours: maxHours,
                dayStep: dayStep,
                minuteStep: minuteStep,
                secondStep: secondStep,
                showDays: showDays,
                showHours: showHours,
                showMinutes: showMinutes,
                showSeconds: showSeconds,
                onChanged: enabled ? handleChanged : null,
                loop: loop,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                itemLabel: itemLabel,
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

  /// External duration controller.
  final WheelDurationController? controller;

  @override
  FormFieldState<Duration> createState() => _WheelDurationChoiceFormFieldState();
}

class _WheelDurationChoiceFormFieldState extends FormFieldState<Duration> {
  @override
  WheelDurationChoiceFormField get widget =>
      super.widget as WheelDurationChoiceFormField;

  @override
  void initState() {
    super.initState();
    widget.controller?.valueListenable.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(WheelDurationChoiceFormField oldWidget) {
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
      widget.controller!.jumpToDuration(widget.initialValue!);
    }
  }
}
