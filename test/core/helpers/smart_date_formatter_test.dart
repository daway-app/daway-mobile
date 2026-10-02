import 'package:daway_app/core/helpers/smart_date_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats a time today as "اليوم، ..."', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9, 5);

    expect(smartDate(today), 'اليوم، 9:05 ص');
  });

  test('formats a time yesterday as "أمس، ..."', () {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1, 16, 20);

    expect(smartDate(yesterday), 'أمس، 4:20 م');
  });

  test('formats an older date with the Arabic month name', () {
    final older = DateTime(2025, 5, 3, 11, 15);

    expect(smartDate(older), '3 مايو 2025، 11:15 ص');
  });

  test('formats midnight as 12 ص (12-hour wraparound)', () {
    expect(smartDate(DateTime(2025, 5, 3, 0, 0)), '3 مايو 2025، 12:00 ص');
  });

  test('formats noon as 12 م (12-hour wraparound)', () {
    expect(smartDate(DateTime(2025, 5, 3, 12, 0)), '3 مايو 2025، 12:00 م');
  });

  group('relative time', () {
    // Pinned so "today" and "yesterday" never depend on when the test runs.
    final now = DateTime(2025, 5, 3, 12, 0);

    test('says "الآن" for under a minute, and for a time slightly in the future', () {
      expect(relativeTimeAr(DateTime(2025, 5, 3, 11, 59, 30), now: now), 'الآن');
      expect(compactRelativeTimeAr(DateTime(2025, 5, 3, 11, 59, 30), now: now), 'الآن');
      expect(compactRelativeTimeAr(DateTime(2025, 5, 3, 12, 5), now: now), 'الآن');
    });

    test('spells minutes and hours out in the long form, in correct agreement', () {
      expect(relativeTimeAr(DateTime(2025, 5, 3, 11, 55), now: now), 'منذ 5 دقائق');
      expect(relativeTimeAr(DateTime(2025, 5, 3, 11, 58), now: now), 'منذ دقيقتين');
      expect(relativeTimeAr(DateTime(2025, 5, 3, 11, 0), now: now), 'منذ ساعة');
      expect(relativeTimeAr(DateTime(2025, 5, 3, 9, 0), now: now), 'منذ 3 ساعات');
    });

    test('abbreviates minutes and hours in the compact form', () {
      expect(compactRelativeTimeAr(DateTime(2025, 5, 3, 11, 55), now: now), 'منذ 5 د');
      expect(compactRelativeTimeAr(DateTime(2025, 5, 3, 11, 1), now: now), 'منذ 59 د');
      expect(compactRelativeTimeAr(DateTime(2025, 5, 3, 11, 0), now: now), 'منذ 1 س');
      expect(compactRelativeTimeAr(DateTime(2025, 5, 3, 9, 0), now: now), 'منذ 3 س');
    });

    test('reads the same in both forms once it is not today any more', () {
      final yesterday = DateTime(2025, 5, 2, 23, 30);
      final older = DateTime(2025, 4, 20, 9, 15);

      expect(compactRelativeTimeAr(yesterday, now: now), 'أمس');
      expect(compactRelativeTimeAr(older, now: now), '20 أبريل 2025، 9:15 ص');
      expect(relativeTimeAr(older, now: now), compactRelativeTimeAr(older, now: now));
    });
  });
}
