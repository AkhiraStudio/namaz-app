extension DateTimeExtensions on DateTime {
  String get dateKey =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  String get timeHHmm =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  bool isSameDayAs(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday {
    final now = DateTime.now();
    return isSameDayAs(now);
  }
}
