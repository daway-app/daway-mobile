const _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

/// "اليوم، 9:40 ص" / "أمس، 4:20 م" / "3 مايو 2025، 11:15 ص" — shared by every
/// card that shows a record's timestamp (patient inquiries, ratings, ...) so
/// they all read the same way. Compares calendar-date components directly
/// (year/month/day), not a Duration subtracted between two DateTimes, so a
/// DST transition day (a real 23h or 25h gap between two local midnights)
/// can't misclassify "today" as "yesterday" or vice versa.
String smartDate(DateTime dateTime) {
  final now = DateTime.now();
  final time = _formatTime(dateTime);

  if (_isSameDate(dateTime, now)) return 'اليوم، $time';
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (_isSameDate(dateTime, yesterday)) return 'أمس، $time';
  return '${dateTime.day} ${_arabicMonths[dateTime.month - 1]} ${dateTime.year}، $time';
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatTime(DateTime dateTime) {
  final isAm = dateTime.hour < 12;
  var hour12 = dateTime.hour % 12;
  if (hour12 == 0) hour12 = 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour12:$minute ${isAm ? 'ص' : 'م'}';
}
