import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/common/types.dart';
import 'builder.dart';
import 'controller.dart';
import 'flex.dart';
import 'header.dart';
import 'label.dart';
import 'order.dart';

/// A composite wheel selector for picking a calendar date
/// with day, month, and year columns.
class WheelDateChoice extends StatefulWidget {
  /// Creates a date picker wheel.
  const WheelDateChoice({
    super.key,
    this.value,
    this.onChanged,
    this.disableDate,
    this.minDate,
    this.maxDate,
    this.minYear,
    this.maxYear,
    this.radiusYear,
    this.anchorYear,
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
    this.order,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  }) : controller = null;

  /// Creates a date picker wheel using an external [controller].
  const WheelDateChoice.raw({
    super.key,
    required WheelDateController this.controller,
    this.itemExtent,
    this.itemVisible,
    this.itemBuilder,
    this.itemLabel,
    this.flex,
    this.expanded,
    this.header,
    this.overlay,
    this.effect,
    this.order,
    this.spacing,
    this.physics,
    this.clipBehavior,
    this.keyboard,
    this.focusNode,
    this.haptics,
  })  : value = null,
        onChanged = null,
        disableDate = null,
        minDate = null,
        maxDate = null,
        minYear = null,
        maxYear = null,
        radiusYear = null,
        anchorYear = null,
        loop = null;

  /// Input value used when internally creating a controller.
  final DateTime? value;

  /// Emits when a date changes (used with internal controller).
  final ValueChanged<DateTime>? onChanged;

  /// Additional date-level disabling (used with internal controller).
  final ValueTransformer<DateTime, bool>? disableDate;

  /// Min/max constraints (used with internal controller).
  final DateTime? minDate;
  final DateTime? maxDate;
  final int? minYear;
  final int? maxYear;
  final int? radiusYear;
  final int? anchorYear;
  final bool? loop;

  /// Height of each wheel item.
  final double? itemExtent;

  /// Number of visible items in each wheel.
  final int? itemVisible;

  /// Optional per-part custom item builders.
  final WheelDateBuilder? itemBuilder;

  /// Optional per-part labels/formatters for values.
  final WheelDateLabel? itemLabel;

  /// Column flex values for day/month/year.
  final WheelDateFlex? flex;

  /// Whether the wheel columns expand to fill available width.
  final bool? expanded;

  /// Optional header widget configuration for each column.
  final WheelDateHeader? header;

  /// Optional overlay builder placed over the wheels.
  final WidgetBuilder? overlay;

  /// Visual effect applied to the wheel items.
  final WheelEffect? effect;

  /// Order of columns; defaults to locale-aware order.
  final WheelDateOrder? order;

  /// Horizontal spacing between columns.
  final double? spacing;

  /// Optional scroll physics forwarded to each wheel.
  final ScrollPhysics? physics;

  /// Viewport clipping behavior.
  final Clip? clipBehavior;

  /// Whether keyboard navigation is enabled.
  final bool? keyboard;

  /// Optional focus node for keyboard events.
  final FocusNode? focusNode;

  /// Whether haptic feedback is played on selection changes.
  final bool? haptics;

  /// Optional external controller. If null, an internal one is created.
  final WheelDateController? controller;

  @override
  State<WheelDateChoice> createState() => _WheelDateChoiceState();
}

class _WheelDateChoiceState extends State<WheelDateChoice> {
  WheelDateController? _defaultCtrl;
  WheelDateController get _ctrl => widget.controller ?? _ensureCtrl();
  WheelDateController _ensureCtrl() {
    return _defaultCtrl ??= WheelDateController(
      value: widget.value ?? DateTime.now(),
      onChanged: widget.onChanged,
      disableDate: widget.disableDate,
      minDate: widget.minDate,
      maxDate: widget.maxDate,
      minYear: widget.minYear,
      maxYear: widget.maxYear,
      radiusYear: widget.radiusYear,
      anchorYear: widget.anchorYear,
      loop: widget.loop,
    );
  }

  WheelDateFlex? _defaultFlex;
  WheelDateFlex _ensureFlex() => _defaultFlex ??= const WheelDateFlex();
  WheelDateFlex get _flex => widget.flex ?? _ensureFlex();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant WheelDateChoice oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    if (widget.controller == null) {
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToDate(widget.value!, notify: false);
      }

      if (widget.minDate != oldWidget.minDate ||
          widget.maxDate != oldWidget.maxDate ||
          widget.minYear != oldWidget.minYear ||
          widget.maxYear != oldWidget.maxYear ||
          widget.radiusYear != oldWidget.radiusYear ||
          widget.anchorYear != oldWidget.anchorYear) {
        _ctrl.setOptions(
          minDate: widget.minDate,
          maxDate: widget.maxDate,
          minYear: widget.minYear,
          maxYear: widget.maxYear,
          radiusYear: widget.radiusYear,
          anchorYear: widget.anchorYear,
        );
      }

      if (widget.onChanged != oldWidget.onChanged) {
        _ctrl.setOnChanged(widget.onChanged);
      }

      if (widget.disableDate != oldWidget.disableDate) {
        _ctrl.setDisableDate(widget.disableDate);
      }

      if (widget.loop != oldWidget.loop) {
        _ctrl.setLoop(widget.loop);
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

    final label = widget.itemLabel ?? WheelDateLabel.of(context);

    final dayPicker = Expanded(
      flex: _flex.day,
      child: WheelChoice<int>.raw(
        itemExtent: effectiveItemExtent,
        itemVisible: effectiveItemVisible,
        itemLabel: label.day,
        itemBuilder: widget.itemBuilder?.day,
        overlay: (ctx) => const SizedBox.shrink(),
        expanded: widget.expanded,
        effect: effectiveEffect,
        physics: effectivePhysics,
        clipBehavior: effectiveClipBehavior,
        keyboard: effectiveKeyboard,
        focusNode: widget.focusNode,
        haptics: effectiveHaptics,
        controller: _ctrl.day,
      ),
    );

    final monthPicker = Expanded(
      flex: _flex.month,
      child: WheelChoice<int>.raw(
        itemExtent: effectiveItemExtent,
        itemVisible: effectiveItemVisible,
        itemLabel: label.month,
        itemBuilder: widget.itemBuilder?.month,
        overlay: (ctx) => const SizedBox.shrink(),
        expanded: widget.expanded,
        effect: effectiveEffect,
        physics: effectivePhysics,
        clipBehavior: effectiveClipBehavior,
        keyboard: effectiveKeyboard,
        focusNode: widget.focusNode,
        haptics: effectiveHaptics,
        controller: _ctrl.month,
      ),
    );

    final yearPicker = Expanded(
      flex: _flex.year,
      child: WheelChoice<int>.raw(
        itemExtent: effectiveItemExtent,
        itemVisible: effectiveItemVisible,
        itemLabel: label.year,
        itemBuilder: widget.itemBuilder?.year,
        overlay: (ctx) => const SizedBox.shrink(),
        expanded: widget.expanded,
        effect: effectiveEffect,
        physics: effectivePhysics,
        clipBehavior: effectiveClipBehavior,
        keyboard: effectiveKeyboard,
        focusNode: widget.focusNode,
        haptics: effectiveHaptics,
        controller: _ctrl.year,
      ),
    );

    final order = widget.order ?? WheelDateOrder.of(context);
    final pickers = [dayPicker, monthPicker, yearPicker];
    final orderedPickers = order.callback(pickers);

    final wheelsOverlay = WheelOverlay(
      builder: effectiveOverlay,
      extent: effectiveItemExtent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withSpacing(orderedPickers, widget.spacing ?? 0),
      ),
    );

    if (widget.header != null) {
      final headers = [
        Expanded(flex: _flex.day, child: widget.header!.dayX),
        Expanded(flex: _flex.month, child: widget.header!.monthX),
        Expanded(flex: _flex.year, child: widget.header!.yearX),
      ];
      final orderedHeaders = order.callback(headers);
      final headersRow = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _withSpacing(orderedHeaders, widget.spacing ?? 0),
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
