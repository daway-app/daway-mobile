import 'arabic_plural.dart';

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
///
/// [now] is the clock to compare against (the current time by default); it
/// exists so a test can pin it.
String smartDate(DateTime dateTime, {DateTime? now}) {
  now ??= DateTime.now();
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
String relativeTimeAr(DateTime dateTime, {DateTime? now}) {
  return _relativeTime(
    dateTime,
    now: now,
    minutesAgo: (minutes) =>
        'منذ ${arabicCountedNoun(minutes, singular: 'دقيقة', dual: 'دقيقتين', plural: 'دقائق')}',
    hoursAgo: (hours) =>
        'منذ ${arabicCountedNoun(hours, singular: 'ساعة', dual: 'ساعتين', plural: 'ساعات')}',
  );
}

/// [relativeTimeAr] with the minutes and hours abbreviated ("منذ 5 د" /
/// "منذ 3 س") — for the tight spot on a card where the full words don't fit
/// (the pharmacy's order cards). Everything older than an hour reads the same
/// as in [relativeTimeAr].
String compactRelativeTimeAr(DateTime dateTime, {DateTime? now}) {
  return _relativeTime(
    dateTime,
    now: now,
    minutesAgo: (minutes) => 'منذ $minutes د',
    hoursAgo: (hours) => 'منذ $hours س',
  );
}

String _relativeTime(
  DateTime dateTime, {
  required DateTime? now,
  required String Function(int minutes) minutesAgo,
  required String Function(int hours) hoursAgo,
}) {
  now ??= DateTime.now();
  if (_isSameDate(dateTime, now)) {
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return minutesAgo(diff.inMinutes);
    return hoursAgo(diff.inHours);
  }
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  if (_isSameDate(dateTime, yesterday)) return 'أمس';
  return smartDate(dateTime, now: now);
}

String _formatTime(DateTime dateTime) {
  final isAm = dateTime.hour < 12;
  var hour12 = dateTime.hour % 12;
  if (hour12 == 0) hour12 = 12;
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour12:$minute ${isAm ? 'ص' : 'م'}';
}
