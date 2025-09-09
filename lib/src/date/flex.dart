class WheelDateFlex {
  WheelDateFlex({
    int? day,
    int? month,
    int? year,
  }) : day = day ?? 3,
       month = month ?? 4,
       year = year ?? 4;

  final int day;
  final int month;
  final int year;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WheelDateFlex &&
        other.day == day &&
        other.month == month &&
        other.year == year;
  }

  @override
  int get hashCode => Object.hash(day, month, year);
}
