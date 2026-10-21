import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'controller.dart';
import 'types.dart';

/// A multi-column cascading wheel selector where downstream options
/// depend on upstream selections (e.g. Country -> State -> City).
class WheelCascadeChoice<T> extends StatefulWidget {
  /// Creates a cascading picker with a hierarchical item tree.
  const WheelCascadeChoice({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.itemExtent,
    this.itemVisible,
    this.itemLabel,
    this.overlay,
    this.effect,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  }) : controller = null;

  /// Creates a cascading picker using an external [controller].
  const WheelCascadeChoice.raw({
    super.key,
    required WheelCascadeController<T> this.controller,
    this.itemExtent,
    this.itemVisible,
    this.itemLabel,
    this.overlay,
    this.effect,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  })  : items = const [],
        value = null,
        onChanged = null;

  /// The root hierarchical options.
  final List<WheelCascadeItem<T>> items;

  /// Initial values.
  final List<T>? value;

  /// Callback when values change.
  final ValueChanged<List<T>>? onChanged;

  /// Height of each item row.
  final double? itemExtent;

  /// Number of visible rows.
  final int? itemVisible;

  /// Label formatting callback.
  final WheelItemLabel<T>? itemLabel;

  /// Overlay builder.
  final WidgetBuilder? overlay;

  /// 3D and magnification effect.
  final WheelEffect? effect;

  /// Horizontal spacing between columns.
  final double? spacing;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Viewport clipping behavior.
  final Clip? clipBehavior;

  /// Whether keyboard navigation is enabled.
  final bool? keyboard;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Whether haptic feedback is played.
  final bool? haptics;

  /// External cascade controller.
  final WheelCascadeController<T>? controller;

  @override
  State<WheelCascadeChoice<T>> createState() => _WheelCascadeChoiceState<T>();
}

class _WheelCascadeChoiceState<T> extends State<WheelCascadeChoice<T>> {
  WheelCascadeController<T>? _defaultCtrl;
  WheelCascadeController<T> get _ctrl => widget.controller ?? _ensureCtrl();

  WheelCascadeController<T> _ensureCtrl() {
    return _defaultCtrl ??= WheelCascadeController<T>(
      items: widget.items,
      initialValue: widget.value,
      onChanged: widget.onChanged,
    );
  }

  @override
  void didUpdateWidget(covariant WheelCascadeChoice<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    if (widget.controller == null) {
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToValues(widget.value!);
      }
      if (widget.onChanged != oldWidget.onChanged) {
        _ctrl.setOnChanged(widget.onChanged);
      }
    }
  }

  @override
  void dispose() {
    _defaultCtrl?.dispose();
    _defaultCtrl = null;
    super.dispose();
  }

  List<Widget> _withSpacing(List<Widget> items, double spacing) {
    if (spacing <= 0 || items.length <= 1) return items;
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(SizedBox(width: spacing));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = WheelChoiceTheme.of(context);
    final effectiveItemExtent = widget.itemExtent ?? theme?.itemExtent ?? 40.0;
    final effectiveItemVisible = widget.itemVisible ?? theme?.itemVisible;
    final effectiveEffect = widget.effect ?? theme?.effect;
    final effectiveOverlay = widget.overlay ?? theme?.overlay;
    final effectivePhysics = widget.physics ?? theme?.physics;
    final effectiveClipBehavior = widget.clipBehavior ?? theme?.clipBehavior;
    final effectiveKeyboard = widget.keyboard ?? theme?.keyboard;
    final effectiveHaptics = widget.haptics ?? theme?.haptics;

    final pickers = <Widget>[];
    for (var i = 0; i < _ctrl.depth; i++) {
      final ctrl = _ctrl.controllers[i];
      pickers.add(
        Flexible(
          child: WheelChoice<T>.raw(
            controller: ctrl,
            itemExtent: effectiveItemExtent,
            itemVisible: effectiveItemVisible,
            itemLabel: widget.itemLabel,
            effect: effectiveEffect,
            physics: effectivePhysics,
            clipBehavior: effectiveClipBehavior,
            keyboard: effectiveKeyboard,
            focusNode: widget.focusNode,
            haptics: effectiveHaptics,
          ),
        ),
      );
    }

    return WheelOverlay(
      builder: effectiveOverlay,
      extent: effectiveItemExtent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withSpacing(pickers, widget.spacing ?? 0),
      ),
    );
  }
}
