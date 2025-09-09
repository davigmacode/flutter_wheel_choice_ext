import 'package:wheel_choice/wheel_choice.dart';

class WheelDateBuilder {
  const WheelDateBuilder({this.day, this.month, this.year});

  const WheelDateBuilder.all(WheelItemBuilder<int>? builder)
    : day = builder,
      month = builder,
      year = builder;

  final WheelItemBuilder<int>? day;
  final WheelItemBuilder<int>? month;
  final WheelItemBuilder<int>? year;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelDateBuilder &&
        other.day == day &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(day, month, year);
}
