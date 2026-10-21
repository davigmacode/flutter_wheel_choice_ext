import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'controller.dart';
import 'header.dart';
import 'label.dart';

/// A composite wheel selector for picking a duration (hours, minutes, seconds).
class WheelDurationChoice extends StatefulWidget {
  /// Creates a duration picker wheel.
  const WheelDurationChoice({
    super.key,
    this.value,
    this.maxHours = 23,
    this.minuteStep = 1,
    this.secondStep = 1,
    this.showHours = true,
    this.showMinutes = true,
    this.showSeconds = true,
    this.onChanged,
    this.loop,
    this.itemExtent,
    this.itemVisible,
    this.itemLabel,
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

  /// Creates a duration picker wheel using an external [controller].
  const WheelDurationChoice.raw({
    super.key,
    required WheelDurationController this.controller,
    this.itemExtent,
    this.itemVisible,
    this.itemLabel,
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
        maxHours = null,
        minuteStep = null,
        secondStep = null,
        showHours = null,
        showMinutes = null,
        showSeconds = null,
        onChanged = null,
        loop = null;

  /// Initial duration value.
  final Duration? value;

  /// Maximum selectable hours.
  final int? maxHours;

  /// Minute interval step.
  final int? minuteStep;

  /// Second interval step.
  final int? secondStep;

  /// Whether to display hours.
  final bool? showHours;

  /// Whether to display minutes.
  final bool? showMinutes;

  /// Whether to display seconds.
  final bool? showSeconds;

  /// Callback when duration changes.
  final ValueChanged<Duration>? onChanged;

  /// Whether wheels loop continuously.
  final bool? loop;

  /// Height of each row item.
  final double? itemExtent;

  /// Number of visible rows.
  final int? itemVisible;

  /// Labels for formatting column values.
  final WheelDurationLabel? itemLabel;

  /// Headers above columns.
  final WheelDurationHeader? header;

  /// Overlay highlighting selected row.
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

  /// External duration controller.
  final WheelDurationController? controller;

  @override
  State<WheelDurationChoice> createState() => _WheelDurationChoiceState();
}

class _WheelDurationChoiceState extends State<WheelDurationChoice> {
  WheelDurationController? _defaultCtrl;
  WheelDurationController get _ctrl => widget.controller ?? _ensureCtrl();

  WheelDurationController _ensureCtrl() {
    return _defaultCtrl ??= WheelDurationController(
      value: widget.value ?? Duration.zero,
      maxHours: widget.maxHours ?? 23,
      minuteStep: widget.minuteStep ?? 1,
      secondStep: widget.secondStep ?? 1,
      showHours: widget.showHours ?? true,
      showMinutes: widget.showMinutes ?? true,
      showSeconds: widget.showSeconds ?? true,
      onChanged: widget.onChanged,
      loop: widget.loop,
    );
  }

  @override
  void didUpdateWidget(covariant WheelDurationChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    if (widget.controller == null) {
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToDuration(widget.value!, notify: false);
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

    final label = widget.itemLabel ?? WheelDurationLabel.padded();
    final columns = <Widget>[];

    if (_ctrl.showHours) {
      columns.add(
        Flexible(
          child: WheelChoice<int>.raw(
            controller: _ctrl.hours,
            itemExtent: effectiveItemExtent,
            itemVisible: effectiveItemVisible,
            itemLabel: label.hours,
            header: widget.header?.hoursX,
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

    if (_ctrl.showMinutes) {
      columns.add(
        Flexible(
          child: WheelChoice<int>.raw(
            controller: _ctrl.minutes,
            itemExtent: effectiveItemExtent,
            itemVisible: effectiveItemVisible,
            itemLabel: label.minutes,
            header: widget.header?.minutesX,
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

    if (_ctrl.showSeconds) {
      columns.add(
        Flexible(
          child: WheelChoice<int>.raw(
            controller: _ctrl.seconds,
            itemExtent: effectiveItemExtent,
            itemVisible: effectiveItemVisible,
            itemLabel: label.seconds,
            header: widget.header?.secondsX,
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
        children: _withSpacing(columns, widget.spacing ?? 0),
      ),
    );
  }
}
