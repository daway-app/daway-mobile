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
}
