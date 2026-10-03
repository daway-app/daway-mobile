import 'package:daway_app/features/pharmacy/domain/entities/working_hours_entry.dart';
import 'package:daway_app/features/pharmacy/presentation/helpers/working_hours_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatWorkingTimeArabic', () {
    test('writes a morning hour with ص', () {
      expect(formatWorkingTimeArabic('09:00'), '9ص');
    });

    test('writes an evening hour with م', () {
      expect(formatWorkingTimeArabic('22:00'), '10م');
    });

    test('noon is 12م and midnight is 12ص', () {
      expect(formatWorkingTimeArabic('12:00'), '12م');
      expect(formatWorkingTimeArabic('00:00'), '12ص');
    });

    test('keeps the minutes when there are any', () {
      expect(formatWorkingTimeArabic('21:30'), '9:30م');
      expect(formatWorkingTimeArabic('08:05'), '8:05ص');
    });

    test('returns a value it cannot read as it is', () {
      expect(formatWorkingTimeArabic('soon'), 'soon');
    });
  });

  group('parse / format round trip', () {
    test('formatWorkingTime pads to HH:mm', () {
      expect(formatWorkingTime(const TimeOfDay(hour: 9, minute: 5)), '09:05');
    });

    test('parseWorkingTime reads HH:mm and rejects anything else', () {
      expect(parseWorkingTime('09:30'), const TimeOfDay(hour: 9, minute: 30));
      expect(parseWorkingTime(null), isNull);
      expect(parseWorkingTime('9'), isNull);
      expect(parseWorkingTime('aa:bb'), isNull);
    });
  });

  group('summarizeWorkingHours', () {
    test('shows the shared hours when every open day has the same ones', () {
      final summary = summarizeWorkingHours(const [
        WorkingHoursEntry(day: WeekDay.sat, open: '09:00', close: '22:00'),
        WorkingHoursEntry(day: WeekDay.sun, open: '09:00', close: '22:00'),
        WorkingHoursEntry(day: WeekDay.fri),
      ]);
      expect(summary, '9ص - 10م');
    });

    test('says مغلق when no day is open', () {
      expect(
        summarizeWorkingHours(const [WorkingHoursEntry(day: WeekDay.fri)]),
        'مغلق',
      );
      expect(summarizeWorkingHours(const []), 'مغلق');
    });

    test('says حسب اليوم when the open days differ', () {
      final summary = summarizeWorkingHours(const [
        WorkingHoursEntry(day: WeekDay.sat, open: '09:00', close: '22:00'),
        WorkingHoursEntry(day: WeekDay.sun, open: '10:00', close: '18:00'),
      ]);
      expect(summary, 'حسب اليوم');
    });
  });
}
