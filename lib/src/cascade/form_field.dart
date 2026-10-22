import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'choice.dart';
import 'controller.dart';
import 'types.dart';

/// A [FormField] that contains a [WheelCascadeChoice].
class WheelCascadeChoiceFormField<T> extends FormField<List<T>> {
  /// Creates a [FormField] containing a [WheelCascadeChoice].
  WheelCascadeChoiceFormField({
    super.key,
    this.controller,
    List<WheelCascadeItem<T>> items = const [],
    WheelCascadeOptionsLoader<T>? optionsLoader,
    int? depth,
    List<T>? initialValue,
    ValueChanged<List<T>>? onChanged,
    List<Widget?>? header,
    List<int>? flex,
    double? itemExtent,
    int? itemVisible,
    WheelItemLabel<T>? itemLabel,
    WheelCascadeLoadingBuilder? loadingBuilder,
    WheelCascadeErrorBuilder? errorBuilder,
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
          builder: (FormFieldState<List<T>> field) {
            final effectiveDecoration = (decoration ?? const InputDecoration())
                .applyDefaults(Theme.of(field.context).inputDecorationTheme);

            void handleChanged(List<T> value) {
              field.didChange(value);
              onChanged?.call(value);
            }

            final effectivePhysics =
                enabled ? physics : const NeverScrollableScrollPhysics();

            Widget wheel;
            if (controller != null) {
              wheel = WheelCascadeChoice<T>.raw(
                controller: controller,
                header: header,
                flex: flex,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                itemLabel: itemLabel,
                loadingBuilder: loadingBuilder,
                errorBuilder: errorBuilder,
                overlay: overlay,
                effect: effect,
                spacing: spacing,
                physics: effectivePhysics,
                clipBehavior: clipBehavior,
                keyboard: enabled ? keyboard : false,
                focusNode: focusNode,
                haptics: enabled ? haptics : false,
              );
            } else if (optionsLoader != null) {
              wheel = WheelCascadeChoice<T>.builder(
                depth: depth ?? 0,
                optionsLoader: optionsLoader,
                value: field.value,
                onChanged: enabled ? handleChanged : null,
                header: header,
                flex: flex,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                itemLabel: itemLabel,
                loadingBuilder: loadingBuilder,
                errorBuilder: errorBuilder,
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
              wheel = WheelCascadeChoice<T>(
                items: items,
                value: field.value,
                onChanged: enabled ? handleChanged : null,
                header: header,
                flex: flex,
                itemExtent: itemExtent,
                itemVisible: itemVisible,
                itemLabel: itemLabel,
                loadingBuilder: loadingBuilder,
                errorBuilder: errorBuilder,
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
              isEmpty: field.value == null || field.value!.isEmpty,
              child: wheel,
            );
          },
        );

  /// External cascade controller.
  final WheelCascadeController<T>? controller;

  @override
  FormFieldState<List<T>> createState() =>
      _WheelCascadeChoiceFormFieldState<T>();
}

class _WheelCascadeChoiceFormFieldState<T> extends FormFieldState<List<T>> {
  @override
  WheelCascadeChoiceFormField<T> get widget =>
      super.widget as WheelCascadeChoiceFormField<T>;

  @override
  void initState() {
    super.initState();
    widget.controller?.valueListenable.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(WheelCascadeChoiceFormField<T> oldWidget) {
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
      widget.controller!.jumpToValues(widget.initialValue!);
    }
  }
}
