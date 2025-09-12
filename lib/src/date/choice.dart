import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'builder.dart';
import 'flex.dart';
import 'header.dart';
import 'label.dart';
import 'order.dart';
import 'controller.dart';

/// A composite wheel selector for picking a calendar date
/// with day, month, and year columns.
class WheelDateChoice extends StatefulWidget {
  /// Creates a date picker wheel.
  const WheelDateChoice.raw({
    super.key,
    required this.controller,
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
  });

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
  final WheelDateController controller;

  @override
  /// Creates the mutable state for this widget.
  State<WheelDateChoice> createState() => _WheelDateChoiceState();
}

class _WheelDateChoiceState extends State<WheelDateChoice> {
  late final WheelDateController _controller;

  int? get _itemVisible => widget.itemVisible;
  double get _itemExtent => widget.itemExtent ?? 40;

  WheelDateLabel get _label {
    return widget.itemLabel ?? WheelDateLabel.of(context);
  }

  WheelDateFlex get _flex => widget.flex ?? WheelDateFlex();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
  }

  @override
  void dispose() {
    _controller.dispose();
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
        controller: _controller.day,
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
        controller: _controller.month,
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
        controller: _controller.year,
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
