import 'package:flutter/material.dart';
import 'package:wheel_choice/wheel_choice.dart';
import 'builder.dart';
import 'flex.dart';
import 'header.dart';
import 'label.dart';
import 'order.dart';

class WheelDateChoice extends StatefulWidget {
  WheelDateChoice({
    super.key,
    DateTime? value,
    this.onChanged,
    this.itemExtent,
    this.itemVisible,
    this.itemBuilder,
    this.label,
    this.flex,
    this.expanded,
    this.header,
    this.overlay,
    this.effect,
    this.order,
    this.spacing,
    this.minDate,
    this.maxDate,
    this.minYear,
    this.maxYear,
  }) : value = value ?? DateTime.now();

  final DateTime value;
  final ValueChanged<DateTime>? onChanged;
  final double? itemExtent;
  final int? itemVisible;
  final WheelDateBuilder? itemBuilder;
  final WheelDateLabel? label;
  final WheelDateFlex? flex;
  final bool? expanded;
  final WheelDateHeader? header;
  final WidgetBuilder? overlay;
  final WheelEffect? effect;
  final WheelDateOrder? order;
  final double? spacing;
  final DateTime? minDate;
  final DateTime? maxDate;
  final int? minYear;
  final int? maxYear;

  @override
  State<WheelDateChoice> createState() => _WheelDateChoiceState();
}

class _WheelDateChoiceState extends State<WheelDateChoice> {
  late int _selectedYear;
  late int _selectedMonth;
  late int _selectedDay;

  int? get _itemVisible => widget.itemVisible;
  double get _itemExtent => widget.itemExtent ?? 40;

  List<int> get _yearOptions {
    final min = widget.minYear ?? widget.minDate?.year ?? 1900;
    final max = widget.maxYear ?? widget.maxDate?.year ?? 2100;
    return List.generate(max - min + 1, (i) => min + i);
  }

  List<int> get _monthOptions => List.generate(12, (i) => i + 1);

  List<int> get _dayOptions => List.generate(31, (i) => i + 1);

  WheelDateLabel get _label {
    return widget.label ?? WheelDateLabel.of(context);
  }

  WheelDateFlex get _flex => widget.flex ?? WheelDateFlex();

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.value.year;
    _selectedMonth = widget.value.month;
    _selectedDay = widget.value.day;
  }

  void _emitDateChanged() {
    final date = DateTime(_selectedYear, _selectedMonth, _selectedDay);
    widget.onChanged?.call(date);
  }

  bool _isValidDate(int year, int month, int day) {
    try {
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return false;
      }
      if (widget.minDate != null && date.isBefore(widget.minDate!)) {
        return false;
      }
      if (widget.maxDate != null && date.isAfter(widget.maxDate!)) return false;
      return true;
    } catch (_) {
      return false;
    }
  }

  bool _isDisabledDay(int d) => !_isValidDate(_selectedYear, _selectedMonth, d);

  bool _isDisabledMonth(int m) => !_isValidDate(_selectedYear, m, _selectedDay);

  bool _isDisabledYear(int y) {
    if (widget.minYear != null && y < widget.minYear!) return true;
    if (widget.maxYear != null && y > widget.maxYear!) return true;
    return !_isValidDate(y, _selectedMonth, _selectedDay);
  }

  void _onYearChanged(int year) {
    setState(() {
      _selectedYear = year;
      if (!_isValidDate(_selectedYear, _selectedMonth, _selectedDay)) {
        _selectedDay = 1;
      }
    });
    _emitDateChanged();
  }

  void _onMonthChanged(int month) {
    setState(() {
      _selectedMonth = month;
      if (!_isValidDate(_selectedYear, _selectedMonth, _selectedDay)) {
        _selectedDay = 1;
      }
    });
    _emitDateChanged();
  }

  void _onDayChanged(int day) {
    setState(() => _selectedDay = day);
    _emitDateChanged();
  }

  @override
  Widget build(BuildContext context) {
    final dayPicker = Flexible(
      flex: _flex.day,
      child: WheelChoice<int>(
        options: _dayOptions,
        value: _selectedDay,
        onChanged: _onDayChanged,
        itemExtent: _itemExtent,
        itemVisible: _itemVisible,
        itemDisabled: _isDisabledDay,
        itemLabel: _label.day,
        itemBuilder: widget.itemBuilder?.day,
        header: widget.header?.dayX,
        expanded: widget.expanded,
        effect: widget.effect,
        loop: true,
      ),
    );

    final monthPicker = Flexible(
      flex: _flex.month,
      child: WheelChoice<int>(
        options: _monthOptions,
        value: _selectedMonth,
        onChanged: _onMonthChanged,
        itemExtent: _itemExtent,
        itemVisible: _itemVisible,
        itemDisabled: _isDisabledMonth,
        itemLabel: _label.month,
        itemBuilder: widget.itemBuilder?.month,
        header: widget.header?.monthX,
        expanded: widget.expanded,
        effect: widget.effect,
        loop: true,
      ),
    );

    final yearPicker = Flexible(
      flex: _flex.year,
      child: WheelChoice<int>(
        options: _yearOptions,
        value: _selectedYear,
        onChanged: _onYearChanged,
        itemExtent: _itemExtent,
        itemVisible: _itemVisible,
        itemDisabled: _isDisabledYear,
        itemLabel: _label.year,
        itemBuilder: widget.itemBuilder?.year,
        header: widget.header?.yearX,
        expanded: widget.expanded,
        effect: widget.effect,
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
