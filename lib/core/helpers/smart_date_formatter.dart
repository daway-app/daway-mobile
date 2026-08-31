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

/// "الآن" / "منذ 5 دقائق" / "منذ ساعة" / "أمس" / falls back to [smartDate]
/// for anything older — used where a feed reads more naturally as relative
/// time (notifications) than the "اليوم، H:MM" style [smartDate] renders for
/// cards where the exact time of day matters (inquiries, ratings).
String relativeTimeAr(DateTime dateTime) {
  final now = DateTime.now();
  if (_isSameDate(dateTime, now)) {
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) {
      return 'منذ ${_arabicCount(diff.inMinutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
    }
    return 'منذ ${_arabicCount(diff.inHours, 'ساعة', 'ساعتين', 'ساعات')}';
  }
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (_isSameDate(dateTime, yesterday)) return 'أمس';
  return smartDate(dateTime);
}

/// Arabic numeral-noun agreement: 1 -> singular alone, 2 -> dual alone,
/// 3-10 -> number + plural, 11+ -> number + singular (e.g. "5 دقائق" but
/// "20 دقيقة") — getting this right matters here since, unlike the simple
/// "$count تقييم" counters elsewhere in the app, a relative-time feed shows
/// both a 5 and a 20 side by side often enough for the wrong form to stand
/// out.
String _arabicCount(int count, String singular, String dual, String plural) {
  if (count == 1) return singular;
  if (count == 2) return dual;
  if (count >= 3 && count <= 10) return '$count $plural';
  return '$count $singular';
}

String _formatTime(DateTime dateTime) {
  final isAm = dateTime.hour < 12;
  var hour12 = dateTime.hour % 12;
  if (hour12 == 0) hour12 = 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour12:$minute ${isAm ? 'ص' : 'م'}';
}
