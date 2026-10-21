import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/date/builder.dart';
import 'package:wheel_choice_ext/src/date/choice.dart';
import 'package:wheel_choice_ext/src/date/flex.dart';
import 'package:wheel_choice_ext/src/date/header.dart';
import 'package:wheel_choice_ext/src/date/label.dart';
import 'package:wheel_choice_ext/src/date/order.dart';
import 'controller.dart';

/// A composite wheel selector for picking a start and end date range.
class WheelDateRangeChoice extends StatefulWidget {
  /// Creates a date range picker wheel.
  const WheelDateRangeChoice({
    super.key,
    this.value,
    this.onChanged,
    this.minYear,
    this.maxYear,
    this.radiusYear,
    this.anchorYear,
    this.loop,
    this.itemExtent,
    this.itemVisible,
    this.dateBuilder,
    this.dateLabel,
    this.dateFlex,
    this.dateHeader,
    this.dateOrder,
    this.startHeader,
    this.endHeader,
    this.overlay,
    this.effect,
    this.spacing,
    this.separator,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  }) : controller = null;

  /// Creates a date range picker wheel using an external [controller].
  const WheelDateRangeChoice.raw({
    super.key,
    required WheelDateRangeController this.controller,
    this.itemExtent,
    this.itemVisible,
    this.dateBuilder,
    this.dateLabel,
    this.dateFlex,
    this.dateHeader,
    this.dateOrder,
    this.startHeader,
    this.endHeader,
    this.overlay,
    this.effect,
    this.spacing,
    this.separator,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  })  : value = null,
        onChanged = null,
        minYear = null,
        maxYear = null,
        radiusYear = null,
        anchorYear = null,
        loop = null;

  /// Initial date range.
  final DateTimeRange? value;

  /// Emits when the selected date range changes.
  final ValueChanged<DateTimeRange>? onChanged;

  /// Year boundaries.
  final int? minYear;
  final int? maxYear;
  final int? radiusYear;
  final int? anchorYear;
  final bool? loop;

  /// Height of each row item.
  final double? itemExtent;

  /// Number of visible rows.
  final int? itemVisible;

  /// Custom builders for date columns.
  final WheelDateBuilder? dateBuilder;

  /// Labels for date columns.
  final WheelDateLabel? dateLabel;

  /// Column flex ratios for date.
  final WheelDateFlex? dateFlex;

  /// Column headers for date.
  final WheelDateHeader? dateHeader;

  /// Column ordering for date.
  final WheelDateOrder? dateOrder;

  /// Header widget above the start date section.
  final Widget? startHeader;

  /// Header widget above the end date section.
  final Widget? endHeader;

  /// Overlay builder.
  final WidgetBuilder? overlay;

  /// 3D and magnification effect.
  final WheelEffect? effect;

  /// Horizontal spacing.
  final double? spacing;

  /// Separator between start and end sections.
  final Widget? separator;

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

  /// External date range controller.
  final WheelDateRangeController? controller;

  @override
  State<WheelDateRangeChoice> createState() => _WheelDateRangeChoiceState();
}

class _WheelDateRangeChoiceState extends State<WheelDateRangeChoice> {
  WheelDateRangeController? _defaultCtrl;
  WheelDateRangeController get _ctrl => widget.controller ?? _ensureCtrl();

  WheelDateRangeController _ensureCtrl() {
    final now = DateTime.now();
    return _defaultCtrl ??= WheelDateRangeController(
      value: widget.value ?? DateTimeRange(start: now, end: now),
      onChanged: widget.onChanged,
      minYear: widget.minYear,
      maxYear: widget.maxYear,
      radiusYear: widget.radiusYear,
      anchorYear: widget.anchorYear,
      loop: widget.loop,
    );
  }

  @override
  void didUpdateWidget(covariant WheelDateRangeChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    if (widget.controller == null) {
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToRange(widget.value!, notify: false);
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

    final startPicker = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.startHeader != null) widget.startHeader!,
        WheelDateChoice.raw(
          controller: _ctrl.start,
          itemExtent: effectiveItemExtent,
          itemVisible: effectiveItemVisible,
          itemBuilder: widget.dateBuilder,
          itemLabel: widget.dateLabel,
          flex: widget.dateFlex,
          header: widget.dateHeader,
          order: widget.dateOrder,
          effect: effectiveEffect,
          spacing: widget.spacing,
          physics: effectivePhysics,
          clipBehavior: effectiveClipBehavior,
          keyboard: effectiveKeyboard,
          focusNode: widget.focusNode,
          haptics: effectiveHaptics,
        ),
      ],
    );

    final endPicker = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.endHeader != null) widget.endHeader!,
        WheelDateChoice.raw(
          controller: _ctrl.end,
          itemExtent: effectiveItemExtent,
          itemVisible: effectiveItemVisible,
          itemBuilder: widget.dateBuilder,
          itemLabel: widget.dateLabel,
          flex: widget.dateFlex,
          header: widget.dateHeader,
          order: widget.dateOrder,
          effect: effectiveEffect,
          spacing: widget.spacing,
          physics: effectivePhysics,
          clipBehavior: effectiveClipBehavior,
          keyboard: effectiveKeyboard,
          focusNode: widget.focusNode,
          haptics: effectiveHaptics,
        ),
      ],
    );

    final separator = widget.separator ??
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.spacing ?? 8),
          child: SizedBox(
            height: (effectiveItemVisible ?? 5) * effectiveItemExtent,
            child: const VerticalDivider(width: 1),
          ),
        );

    return WheelOverlay(
      builder: effectiveOverlay,
      extent: effectiveItemExtent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: startPicker),
          separator,
          Expanded(child: endPicker),
        ],
      ),
    );
  }
}
