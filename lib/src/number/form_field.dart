import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'choice.dart';
import 'controller.dart';
import 'header.dart';

/// A [FormField] that contains a [WheelNumberChoice].
class WheelNumberChoiceFormField extends FormField<double> {
  /// Creates a [FormField] containing a [WheelNumberChoice].
  WheelNumberChoiceFormField({
    super.key,
    this.controller,
    double? initialValue,
    double min = 0,
    double max = 100,
    double step = 1,
    int precision = 1,
    List<String>? units,
    String? initialUnit,
    ValueChanged<double>? onChanged,
    ValueChanged<String>? onUnitChanged,
    bool? loop,
    double? itemExtent,
    int? itemVisible,
    String decimalSeparator = '.',
    WheelNumberHeader? header,
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
          builder: (FormFieldState<double> field) {
            final effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            void handleChanged(double value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            final effectivePhysics =
                enabled ? physics : const NeverScrollableScrollPhysics();

            Widget wheel;
            if (controller != null) {
              wheel = WheelNumberChoice.raw(
                controller: controller,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                decimalSeparator: decimalSeparator,
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
              wheel = WheelNumberChoice(
                value: field.value,
                min: min,
                max: max,
                step: step,
                precision: precision,
                units: units,
                initialUnit: initialUnit,
                onChanged: enabled ? handleChanged : null,
                onUnitChanged: onUnitChanged,
                loop: loop,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                decimalSeparator: decimalSeparator,
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

  /// External number controller.
  final WheelNumberController? controller;

  @override
  FormFieldState<double> createState() => _WheelNumberChoiceFormFieldState();
}

class _WheelNumberChoiceFormFieldState extends FormFieldState<double> {
  @override
  WheelNumberChoiceFormField get widget =>
      super.widget as WheelNumberChoiceFormField;

  @override
  void initState() {
    super.initState();
    widget.controller?.valueListenable.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(WheelNumberChoiceFormField oldWidget) {
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
      widget.controller!.jumpToValue(widget.initialValue!);
    }
  }
}
