import 'package:wheel_choice/wheel_choice.dart';

class WheelDateHeader extends WheelHeader {
  const WheelDateHeader({
    super.key,
    super.align,
    super.decoration,
    super.textStyle,
    super.extent,
    required this.day,
    required this.month,
    required this.year,
  });

  final WheelHeader day;
  final WheelHeader month;
  final WheelHeader year;

  WheelHeader get dayX => asDefaultFor(day);
  WheelHeader get monthX => asDefaultFor(month);
  WheelHeader get yearX => asDefaultFor(year);
}
