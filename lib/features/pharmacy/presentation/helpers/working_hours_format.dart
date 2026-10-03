import 'package:flutter/material.dart';

import '../../domain/entities/working_hours_entry.dart';

const weekDayLabels = {
  WeekDay.sat: 'السبت',
  WeekDay.sun: 'الأحد',
  WeekDay.mon: 'الاثنين',
  WeekDay.tue: 'الثلاثاء',
  WeekDay.wed: 'الأربعاء',
  WeekDay.thu: 'الخميس',
  WeekDay.fri: 'الجمعة',
};

/// "09:00" -> 9:00, or null when it is not an `HH:mm` string.
TimeOfDay? parseWorkingTime(String? value) {
  if (value == null) return null;
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

/// 9:00 -> "09:00", the form the API stores.
String formatWorkingTime(TimeOfDay time) {
  return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
}

/// "21:30" -> "9:30م", "09:00" -> "9ص", "12:00" -> "12م", "00:00" -> "12ص".
/// Falls back to the raw value when it cannot be read.
String formatWorkingTimeArabic(String value) {
  final time = parseWorkingTime(value);
  if (time == null) return value;
  final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
  final minutes = time.minute == 0
      ? ''
      : ':${time.minute.toString().padLeft(2, '0')}';
  return '$hour12$minutes${time.period == DayPeriod.am ? 'ص' : 'م'}';
}

/// One line for the account-info row: the shared hours ("9ص - 10م") when every
/// open day has the same ones, "مغلق" when no day is open, and "حسب اليوم"
/// when the days differ.
String summarizeWorkingHours(List<WorkingHoursEntry> entries) {
  final open = entries.where((e) => e.isOpen).toList();
  if (open.isEmpty) return 'مغلق';
  final first = open.first;
  final sameEveryDay = open.every(
    (e) => e.open == first.open && e.close == first.close,
  );
  if (!sameEveryDay) return 'حسب اليوم';
  return '${formatWorkingTimeArabic(first.open!)} - ${formatWorkingTimeArabic(first.close!)}';
}
