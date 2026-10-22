import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'builder.dart';
import 'controller.dart';
import 'flex.dart';
import 'header.dart';
import 'label.dart';
import 'types.dart';

/// A composite wheel selector for picking time (hour, minute, optional AM/PM period).
class WheelTimeChoice extends StatefulWidget {
  /// Creates a time picker wheel.
  const WheelTimeChoice({
    super.key,
    this.value,
    this.use24hFormat = true,
    this.minuteStep = 1,
    this.onChanged,
    this.loop,
    this.itemExtent,
    this.itemVisible,
    this.itemBuilder,
    this.itemLabel,
    this.flex,
    this.expanded,
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

  /// Creates a time picker wheel using an external [controller].
  const WheelTimeChoice.raw({
    super.key,
    required WheelTimeController this.controller,
    this.itemExtent,
    this.itemVisible,
    this.itemBuilder,
    this.itemLabel,
    this.flex,
    this.expanded,
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
        use24hFormat = null,
        minuteStep = null,
        onChanged = null,
        loop = null;

  /// Initial time value (used when internally creating a controller).
  final TimeOfDay? value;

  /// Whether the picker operates in 24-hour mode.
  final bool? use24hFormat;

  /// Minute interval step.
  final int? minuteStep;

  /// Emits when the selected time changes.
  final ValueChanged<TimeOfDay>? onChanged;

  /// Whether the wheels wrap around continuously.
  final bool? loop;

  /// Height of each wheel item.
  final double? itemExtent;

  /// Number of visible items in each wheel.
  final int? itemVisible;

  /// Custom builders for each wheel item.
  final WheelTimeBuilder? itemBuilder;

  /// Labels for formatting values.
  final WheelTimeLabel? itemLabel;

  /// Column flex factors.
  final WheelTimeFlex? flex;

  /// Whether wheels expand to fill available height.
  final bool? expanded;

  /// Optional headers above each wheel column.
  final WheelTimeHeader? header;

  /// Optional overlay builder.
  final WidgetBuilder? overlay;

  /// Visual 3D and magnification effect.
  final WheelEffect? effect;

  /// Horizontal spacing between columns.
  final double? spacing;

  /// Optional scroll physics.
  final ScrollPhysics? physics;

  /// Viewport clipping behavior.
  final Clip? clipBehavior;

  /// Whether keyboard navigation is enabled.
  final bool? keyboard;

  /// Optional focus node for keyboard events.
  final FocusNode? focusNode;

  /// Whether haptic feedback is played on selection changes.
  final bool? haptics;

  /// Optional external controller.
  final WheelTimeController? controller;

  @override
  State<WheelTimeChoice> createState() => _WheelTimeChoiceState();
}

class _WheelTimeChoiceState extends State<WheelTimeChoice> {
  WheelTimeController? _defaultCtrl;
  WheelTimeController get _ctrl => widget.controller ?? _ensureCtrl();

  WheelTimeController _ensureCtrl() {
    return _defaultCtrl ??= WheelTimeController(
      value: widget.value ?? TimeOfDay.now(),
      use24hFormat: widget.use24hFormat ?? true,
      minuteStep: widget.minuteStep ?? 1,
      onChanged: widget.onChanged,
      loop: widget.loop,
    );
  }

  WheelTimeFlex? _defaultFlex;
  WheelTimeFlex _ensureFlex() => _defaultFlex ??= const WheelTimeFlex();
  WheelTimeFlex get _flex => widget.flex ?? _ensureFlex();

  @override
  void didUpdateWidget(covariant WheelTimeChoice oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    if (widget.controller == null) {
      final configChanged = widget.use24hFormat != oldWidget.use24hFormat ||
          widget.minuteStep != oldWidget.minuteStep ||
          widget.loop != oldWidget.loop;

      if (configChanged && _defaultCtrl != null) {
        final currentVal = widget.value ?? _defaultCtrl!.value;
        _defaultCtrl?.dispose();
        _defaultCtrl = WheelTimeController(
          value: currentVal,
          use24hFormat: widget.use24hFormat ?? true,
          minuteStep: widget.minuteStep ?? 1,
          onChanged: widget.onChanged,
          loop: widget.loop,
        );
      } else {
        if (widget.value != null && widget.value != oldWidget.value) {
          _defaultCtrl?.jumpToTime(widget.value!, notify: false);
        }
        if (widget.onChanged != oldWidget.onChanged) {
          _ctrl.setOnChanged(widget.onChanged);
        }
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

    final label = widget.itemLabel ?? WheelTimeLabel.of(context);
    final hasHeader = widget.header != null;
    final headers = <Widget>[];
    final wheels = <Widget>[];

    if (hasHeader && widget.header!.hourX != null) {
      headers.add(Expanded(flex: _flex.hour, child: widget.header!.hourX!));
    }
    wheels.add(
      Expanded(
        flex: _flex.hour,
        child: WheelChoice<int>.raw(
          itemExtent: effectiveItemExtent,
          itemVisible: effectiveItemVisible,
          itemLabel: label.hour,
          itemBuilder: widget.itemBuilder?.hour,
          overlay: (ctx) => const SizedBox.shrink(),
          expanded: widget.expanded,
          effect: effectiveEffect,
          physics: effectivePhysics,
          clipBehavior: effectiveClipBehavior,
          keyboard: effectiveKeyboard,
          focusNode: widget.focusNode,
          haptics: effectiveHaptics,
          controller: _ctrl.hour,
        ),
      ),
    );

    if (hasHeader && widget.header!.minuteX != null) {
      headers.add(Expanded(flex: _flex.minute, child: widget.header!.minuteX!));
    }
    wheels.add(
      Expanded(
        flex: _flex.minute,
        child: WheelChoice<int>.raw(
          itemExtent: effectiveItemExtent,
          itemVisible: effectiveItemVisible,
          itemLabel: label.minute,
          itemBuilder: widget.itemBuilder?.minute,
          overlay: (ctx) => const SizedBox.shrink(),
          expanded: widget.expanded,
          effect: effectiveEffect,
          physics: effectivePhysics,
          clipBehavior: effectiveClipBehavior,
          keyboard: effectiveKeyboard,
          focusNode: widget.focusNode,
          haptics: effectiveHaptics,
          controller: _ctrl.minute,
        ),
      ),
    );

    if (!_ctrl.use24hFormat && _ctrl.period != null) {
      if (hasHeader && widget.header!.periodX != null) {
        headers.add(Expanded(flex: _flex.period, child: widget.header!.periodX!));
      }
      wheels.add(
        Expanded(
          flex: _flex.period,
          child: WheelChoice<WheelTimePeriod>.raw(
            itemExtent: effectiveItemExtent,
            itemVisible: effectiveItemVisible,
            itemLabel: label.period ?? (p) => p.label,
            itemBuilder: widget.itemBuilder?.period,
            overlay: (ctx) => const SizedBox.shrink(),
            expanded: widget.expanded,
            effect: effectiveEffect,
            physics: effectivePhysics,
            clipBehavior: effectiveClipBehavior,
            keyboard: effectiveKeyboard,
            focusNode: widget.focusNode,
            haptics: effectiveHaptics,
            controller: _ctrl.period!,
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
          widget.expanded == true ? Expanded(child: wheelsOverlay) : wheelsOverlay,
        ],
      );
    }

    return wheelsOverlay;
  }
}
