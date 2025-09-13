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
  }) : controller = null;

  const WheelDateChoice.raw({
    super.key,
    this.controller,
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
  }) : value = null,
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

  /// Optional external controller. If null, an internal one is created.
  final WheelDateController? controller;

  @override
  /// Creates the mutable state for this widget.
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

  double? _defaultItemExtent;
  double _ensureItemExtent() => _defaultItemExtent ??= 40;
  double get _itemExtent => widget.itemExtent ?? _ensureItemExtent();

  WheelDateLabel? _defaultLabel;
  WheelDateLabel _ensureLabel() => _defaultLabel ??= WheelDateLabel.of(context);
  WheelDateLabel get _label => widget.itemLabel ?? _ensureLabel();

  WheelDateFlex? _defaultFlex;
  WheelDateFlex _ensureFlex() => _defaultFlex ??= WheelDateFlex();
  WheelDateFlex get _flex => widget.flex ?? _ensureFlex();

  int? get _itemVisible => widget.itemVisible;

  @override
  void initState() {
    super.initState();
    // Lazy: do not create internal controller here; wait until first use.
  }

  @override
  void didUpdateWidget(covariant WheelDateChoice oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If switching from internal to external controller, dispose internal.
    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    // If using internal controller, update it based on param changes.
    if (widget.controller == null) {
      // Create internal if not yet created and needed later.
      // For value change, keep options stable and jump to the new date.
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToDate(widget.value!);
      }

      // If any constraints or disable logic changed, recreate the controller.
      final constraintsChanged =
          widget.minDate != oldWidget.minDate ||
          widget.maxDate != oldWidget.maxDate ||
          widget.minYear != oldWidget.minYear ||
          widget.maxYear != oldWidget.maxYear ||
          widget.radiusYear != oldWidget.radiusYear ||
          widget.anchorYear != oldWidget.anchorYear ||
          widget.disableDate != oldWidget.disableDate ||
          widget.loop != oldWidget.loop;

      if (constraintsChanged && _defaultCtrl != null) {
        _defaultCtrl!.dispose();
        _defaultCtrl = WheelDateController(
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
    }
  }

  @override
  void dispose() {
    // Dispose internal controller if we created one.
    _defaultCtrl?.dispose();
    _defaultCtrl = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dayPicker = Flexible(
      flex: _flex.day,
      child: WheelChoice<int>.raw(
        itemExtent: _itemExtent,
        itemVisible: _itemVisible,
        itemLabel: _label.day,
        itemBuilder: widget.itemBuilder?.day,
        header: widget.header?.dayX,
        expanded: widget.expanded,
        effect: widget.effect,
        controller: _ctrl.day,
      ),
    );

    final monthPicker = Flexible(
      flex: _flex.month,
      child: WheelChoice<int>.raw(
        itemExtent: _itemExtent,
        itemVisible: _itemVisible,
        itemLabel: _label.month,
        itemBuilder: widget.itemBuilder?.month,
        header: widget.header?.monthX,
        expanded: widget.expanded,
        effect: widget.effect,
        controller: _ctrl.month,
      ),
    );

    final yearPicker = Flexible(
      flex: _flex.year,
      child: WheelChoice<int>.raw(
        itemExtent: _itemExtent,
        itemVisible: _itemVisible,
        itemLabel: _label.year,
        itemBuilder: widget.itemBuilder?.year,
        header: widget.header?.yearX,
        expanded: widget.expanded,
        effect: widget.effect,
        controller: _ctrl.year,
      ),
    );

    final order = widget.order ?? WheelDateOrder.of(context);
    final pickers = [dayPicker, monthPicker, yearPicker];
    final children = order.callback(pickers);

    return WheelOverlay(
      builder: widget.overlay,
      offset: widget.header?.extentX,
      extent: _itemExtent,
      child: Row(
        spacing: widget.spacing ?? 0,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
