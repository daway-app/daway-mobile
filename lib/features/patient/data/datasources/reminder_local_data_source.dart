import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/medicine_reminder.dart';

class ReminderLocalDataSource {
  static const _key = 'medicine_reminders';

  Future<List<MedicineReminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw
        .map((e) => MedicineReminder.fromJson(
            jsonDecode(e) as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveReminders(List<MedicineReminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = reminders.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_key, raw);
  }
}
