import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'package:wheel_choice_ext/src/common/types.dart';
import 'package:wheel_choice_ext/src/date/builder.dart';
import 'package:wheel_choice_ext/src/date/choice.dart';
import 'package:wheel_choice_ext/src/date/flex.dart';
import 'package:wheel_choice_ext/src/date/header.dart';
import 'package:wheel_choice_ext/src/date/label.dart';
import 'package:wheel_choice_ext/src/date/order.dart';
import 'package:wheel_choice_ext/src/time/builder.dart';
import 'package:wheel_choice_ext/src/time/choice.dart';
import 'package:wheel_choice_ext/src/time/flex.dart';
import 'package:wheel_choice_ext/src/time/header.dart';
import 'package:wheel_choice_ext/src/time/label.dart';
import 'controller.dart';

/// A composite wheel selector that combines both date and time pickers.
class WheelDateTimeChoice extends StatefulWidget {
  /// Creates a unified date-and-time picker.
  const WheelDateTimeChoice({
    super.key,
    this.value,
    this.use24hFormat = true,
    this.minuteStep = 1,
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
    this.dateBuilder,
    this.dateLabel,
    this.dateFlex,
    this.dateHeader,
    this.dateOrder,
    this.timeBuilder,
    this.timeLabel,
    this.timeFlex,
    this.timeHeader,
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

  /// Creates a unified date-and-time picker using an external [controller].
  const WheelDateTimeChoice.raw({
    super.key,
    required WheelDateTimeController this.controller,
    this.itemExtent,
    this.itemVisible,
    this.dateBuilder,
    this.dateLabel,
    this.dateFlex,
    this.dateHeader,
    this.dateOrder,
    this.timeBuilder,
    this.timeLabel,
    this.timeFlex,
    this.timeHeader,
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
        use24hFormat = null,
        minuteStep = null,
        onChanged = null,
        disableDate = null,
        minDate = null,
        maxDate = null,
        minYear = null,
        maxYear = null,
        radiusYear = null,
        anchorYear = null,
        loop = null;

  /// Initial selected DateTime.
  final DateTime? value;

  /// Whether time operates in 24-hour mode.
  final bool? use24hFormat;

  /// Minute interval step.
  final int? minuteStep;

  /// Emits whenever the unified DateTime changes.
  final ValueChanged<DateTime>? onChanged;

  /// Predicate to disable specific dates.
  final ValueTransformer<DateTime, bool>? disableDate;

  /// Boundary constraints for date.
  final DateTime? minDate;
  final DateTime? maxDate;
  final int? minYear;
  final int? maxYear;
  final int? radiusYear;
  final int? anchorYear;
  final bool? loop;

  /// Height of each row item across all wheels.
  final double? itemExtent;

  /// Number of visible items across all wheels.
  final int? itemVisible;

  /// Custom builders for date columns.
  final WheelDateBuilder? dateBuilder;

  /// Labels for date columns.
  final WheelDateLabel? dateLabel;

  /// Column flex ratios for date.
  final WheelDateFlex? dateFlex;

  /// Headers for date columns.
  final WheelDateHeader? dateHeader;

  /// Column ordering for date.
  final WheelDateOrder? dateOrder;

  /// Custom builders for time columns.
  final WheelTimeBuilder? timeBuilder;

  /// Labels for time columns.
  final WheelTimeLabel? timeLabel;

  /// Column flex ratios for time.
  final WheelTimeFlex? timeFlex;

  /// Headers for time columns.
  final WheelTimeHeader? timeHeader;

  /// Overlay builder for highlighted row.
  final WidgetBuilder? overlay;

  /// 3D and magnification effect.
  final WheelEffect? effect;

  /// Horizontal spacing between columns.
  final double? spacing;

  /// Optional separator widget between the date and time sections.
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

  /// External unified controller.
  final WheelDateTimeController? controller;

  @override
  State<WheelDateTimeChoice> createState() => _WheelDateTimeChoiceState();
}

class _WheelDateTimeChoiceState extends State<WheelDateTimeChoice> {
  WheelDateTimeController? _defaultCtrl;
  WheelDateTimeController get _ctrl => widget.controller ?? _ensureCtrl();

  WheelDateTimeController _ensureCtrl() {
    return _defaultCtrl ??= WheelDateTimeController(
      value: widget.value ?? DateTime.now(),
      use24hFormat: widget.use24hFormat ?? true,
      minuteStep: widget.minuteStep ?? 1,
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

  @override
  void didUpdateWidget(covariant WheelDateTimeChoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _defaultCtrl?.dispose();
      _defaultCtrl = null;
    }

    if (widget.controller == null) {
      if (widget.value != null && widget.value != oldWidget.value) {
        _defaultCtrl?.jumpToDateTime(widget.value!, notify: false);
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

    final dateWidget = WheelDateChoice.raw(
      controller: _ctrl.date,
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
    );

    final timeWidget = WheelTimeChoice.raw(
      controller: _ctrl.time,
      itemExtent: effectiveItemExtent,
      itemVisible: effectiveItemVisible,
      itemBuilder: widget.timeBuilder,
      itemLabel: widget.timeLabel,
      flex: widget.timeFlex,
      header: widget.timeHeader,
      effect: effectiveEffect,
      spacing: widget.spacing,
      physics: effectivePhysics,
      clipBehavior: effectiveClipBehavior,
      keyboard: effectiveKeyboard,
      focusNode: widget.focusNode,
      haptics: effectiveHaptics,
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
          Expanded(flex: 5, child: dateWidget),
          separator,
          Expanded(
            flex: _ctrl.use24hFormat ? 3 : 4,
            child: timeWidget,
          ),
        ],
      ),
    );
  }
}
