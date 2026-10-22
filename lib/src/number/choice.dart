import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'controller.dart';
import 'header.dart';

/// A composite wheel selector for picking numeric values (integer, decimal fraction, and optional unit).
class WheelNumberChoice extends StatefulWidget {
  /// Creates a number picker wheel.
  const WheelNumberChoice({
    super.key,
    this.value,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.precision = 1,
    this.units,
    this.initialUnit,
    this.onChanged,
    this.onUnitChanged,
    this.loop,
    this.itemExtent,
    this.itemVisible,
    this.decimalSeparator = '.',
    this.header,
    this.overlay,
    this.effect,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  }) : controller = null;

  /// Creates a number picker wheel using an external [controller].
  const WheelNumberChoice.raw({
    super.key,
    required WheelNumberController this.controller,
    this.itemExtent,
    this.itemVisible,
    this.decimalSeparator = '.',
    this.header,
    this.overlay,
    this.effect,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  })  : value = null,
        min = null,
        max = null,
        step = null,
        precision = null,
        units = null,
        initialUnit = null,
        onChanged = null,
        onUnitChanged = null,
        loop = null;

  /// Initial double value.
  final double? value;

  /// Minimum value.
  final double? min;

  /// Maximum value.
  final double? max;

  /// Integer step size.
  final double? step;

  /// Decimal precision.
  final int? precision;

  /// Selectable unit options.
  final List<String>? units;

  /// Initially selected unit.
  final String? initialUnit;

  /// Emits when the numeric value changes.
  final ValueChanged<double>? onChanged;

  /// Emits when the selected unit changes.
  final ValueChanged<String>? onUnitChanged;

  /// Whether integer/decimal wheels loop.
  final bool? loop;

  /// Height of each row item.
  final double? itemExtent;

  /// Number of visible items.
  final int? itemVisible;

  /// Decimal separator string (e.g. `.` or `,`).
  final String decimalSeparator;

  /// Headers above columns.
  final WheelNumberHeader? header;

  /// Overlay builder.
  final WidgetBuilder? overlay;

  /// 3D and magnification effect.
  final WheelEffect? effect;

  /// Horizontal spacing.
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

  /// External number controller.
  final WheelNumberController? controller;

  @override
  State<WheelNumberChoice> createState() => _WheelNumberChoiceState();
}

class _WheelNumberChoiceState extends State<WheelNumberChoice> {
  WheelNumberController? _defaultCtrl;
  WheelNumberController get _ctrl => widget.controller ?? _ensureCtrl();

  WheelNumberController _ensureCtrl() {
    return _defaultCtrl ??= WheelNumberController(
      value: widget.value ?? 0.0,
      min: widget.min ?? 0,
      max: widget.max ?? 100,
      step: widget.step ?? 1,
      precision: widget.precision ?? 1,
      units: widget.units,
      initialUnit: widget.initialUnit,
      onChanged: widget.onChanged,
      onUnitChanged: widget.onUnitChanged,
      loop: widget.loop,
    );
  }

  @override
  void didUpdateWidget(covariant WheelNumberChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    if (widget.controller == null) {
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToValue(widget.value!, notify: false);
      }
      if (widget.onChanged != oldWidget.onChanged) {
        _ctrl.setOnChanged(widget.onChanged);
      }
      if (widget.onUnitChanged != oldWidget.onUnitChanged) {
        _ctrl.setOnUnitChanged(widget.onUnitChanged);
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

    final hasHeader = widget.header != null;
    final headers = <Widget>[];
    final wheels = <Widget>[];

    // Integer column
    if (hasHeader && widget.header!.integerX != null) {
      headers.add(Expanded(flex: 4, child: widget.header!.integerX!));
    }
    wheels.add(
      Expanded(
        flex: 4,
        child: WheelChoice<int>.raw(
          controller: _ctrl.integer,
          itemExtent: effectiveItemExtent,
          itemVisible: effectiveItemVisible,
          overlay: (ctx) => const SizedBox.shrink(),
          effect: effectiveEffect,
          physics: effectivePhysics,
          clipBehavior: effectiveClipBehavior,
          keyboard: effectiveKeyboard,
          focusNode: widget.focusNode,
          haptics: effectiveHaptics,
        ),
      ),
    );

    // Decimal column (if precision > 0)
    if (_ctrl.decimal != null) {
      if (hasHeader) {
        headers.add(const SizedBox(width: 8));
      }
      wheels.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Text(
            widget.decimalSeparator,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      );

      if (hasHeader && widget.header!.decimalX != null) {
        headers.add(Expanded(flex: 3, child: widget.header!.decimalX!));
      }
      wheels.add(
        Expanded(
          flex: 3,
          child: WheelChoice<int>.raw(
            controller: _ctrl.decimal!,
            itemExtent: effectiveItemExtent,
            itemVisible: effectiveItemVisible,
            itemLabel: (v) => v.toString().padLeft(_ctrl.precision, '0'),
            overlay: (ctx) => const SizedBox.shrink(),
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

    // Unit column (if units provided)
    if (_ctrl.unit != null) {
      if (hasHeader && widget.header!.unitX != null) {
        headers.add(Expanded(flex: 3, child: widget.header!.unitX!));
      }
      wheels.add(
        Expanded(
          flex: 3,
          child: WheelChoice<String>.raw(
            controller: _ctrl.unit!,
            itemExtent: effectiveItemExtent,
            itemVisible: effectiveItemVisible,
            overlay: (ctx) => const SizedBox.shrink(),
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

    final wheelsOverlay = WheelOverlay(
      builder: effectiveOverlay,
      extent: effectiveItemExtent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withSpacing(wheels, widget.spacing ?? 0),
      ),
    );

    if (hasHeader && headers.isNotEmpty) {
      final headersRow = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withSpacing(headers, widget.spacing ?? 0),
      );
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          headersRow,
          wheelsOverlay,
        ],
      );
    }

    return wheelsOverlay;
  }
}
