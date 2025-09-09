class WheelDateFlex {
  const WheelDateFlex({
    this.day = 3,
    this.month = 4,
    this.year = 4,
  });

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
